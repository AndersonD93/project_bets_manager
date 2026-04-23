# Bets Manager - Diseño

## Arquitectura General

```
┌─────────────────────────────────────────────────────────────────┐
│              FRONTEND (React + Vite → S3 + CloudFront)          │
│  / Login  /admin  /matches  /results  /bets  /scores            │
│  AuthContext → Cognito SDK → JWT en sessionStorage              │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS (CloudFront → S3 OAC)
                         │ + API calls con JWT
┌────────────────────────▼────────────────────────────────────────┐
│                    API GATEWAY (REST, REGIONAL)                  │
│  Cognito Authorizer (JWT validation)                            │
│  /get_secret (public) │ /put_bets │ /manage_matches             │
│  /update_results      │ /create-matches-football-data           │
└────────────────────────┬────────────────────────────────────────┘
                         │ AWS_PROXY
┌────────────────────────▼────────────────────────────────────────┐
│                      AWS LAMBDA (Python 3.12)                   │
│  get_secret │ put_bets │ manage_matches │ get_matches           │
│  update_results │ get_scores │ create_matches_for_futbol_data   │
│  recalculate_score (DynamoDB Stream trigger)                    │
└──────┬──────────────────────────────────────────────────────────┘
       │
┌──────▼──────────────────────────────────────────────────────────┐
│                        DYNAMODB                                  │
│  matches_table │ results_table (Stream) │ bets_users │ score_user│
└─────────────────────────────────────────────────────────────────┘
       │
┌──────▼──────────────────────────────────────────────────────────┐
│              SECRETS MANAGER + COGNITO + IAM                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Módulos Terraform

### Estructura de Módulos

```
terraform/
├── main.tf                    # Provider, backend S3, módulo resources y tf-state
├── api_gateway.tf             # API Gateway + recursos por endpoint
├── lambda.tf                  # Lambdas + permisos + DynamoDB Stream trigger
├── dynamo.tf                  # Tablas DynamoDB + permisos
├── cognito.tf                 # User Pool, Identity Pool, grupos
├── iam.tf                     # Roles IAM (admin, general, authenticated, unauthenticated)
├── secret_manager.tf          # Secrets Manager (token football-data + config app)
├── locals.tf                  # Nombres de recursos centralizados
├── variables.tf               # Variables de entrada
├── terraform.tfvars           # Valores de variables
├── output.tf                  # Outputs del root module
└── modules/
    ├── resources/             # Módulo principal de recursos
    │   ├── s3.tf              # Bucket S3 para frontend
    │   ├── variables.tf
    │   ├── output.tf
    │   ├── api_gateway/       # Módulo API Gateway
    │   │   ├── main.tf        # aws_api_gateway_rest_api
    │   │   ├── variables.tf
    │   │   ├── output.tf
    │   │   └── api_resources/ # Módulo métodos HTTP
    │   │       ├── main.tf    # aws_api_gateway_method + integration + response
    │   │       ├── locals.tf
    │   │       ├── variables.tf
    │   │       └── output.tf
    │   ├── lambda/            # Módulo Lambda
    │   │   ├── lambda.tf      # aws_lambda_function (map)
    │   │   ├── iam.tf         # Roles de ejecución Lambda
    │   │   ├── variables.tf
    │   │   ├── outputs.tf
    │   │   └── lambda_permission/ # Módulo permisos Lambda
    │   │       ├── main.tf
    │   │       └── variables.tf
    │   └── dynamo_table/      # Módulo DynamoDB
    │       ├── main.tf        # aws_dynamodb_table (map)
    │       ├── variables.tf
    │       ├── outputs.tf
    │       └── dynamo_permission/ # Módulo permisos DynamoDB
    │           ├── main.tf
    │           └── variable.tf
    └── tf-state/              # Módulo backend remoto
        ├── main.tf
        ├── tf-state.tf        # S3 bucket + DynamoDB para state locking
        └── variables.tf
```

---

## Modelo de Datos DynamoDB

### `matches_table`
| Atributo   | Tipo | Descripción                        |
|------------|------|------------------------------------|
| match_id   | S    | PK - Identificador único del partido |
| teams      | S    | Nombre de los equipos              |
| match_date | S    | Fecha del partido                  |
| status     | S    | `SCHEDULED` \| `FINISHED`          |
| updated_at | S    | Timestamp de última actualización  |

### `results_table` (Stream habilitado: NEW_AND_OLD_IMAGES)
| Atributo   | Tipo | Descripción                        |
|------------|------|------------------------------------|
| match_id   | S    | PK - Identificador del partido     |
| exact_score| S    | SK - Marcador exacto (ej: "2-1")   |
| real_result| S    | `home_win` \| `away_win` \| `draw` |
| updated_at | S    | Timestamp de actualización         |

### `bets_users`
| Atributo   | Tipo | Descripción                        |
|------------|------|------------------------------------|
| user_id    | S    | PK - ID del usuario                |
| match_id   | S    | SK - ID del partido apostado       |
| bet_result | S    | Resultado apostado                 |
| exact_score| S    | Marcador exacto apostado           |
| timestamp  | S    | Momento de la apuesta              |
| modified   | BOOL | Si la apuesta fue modificada       |
| score      | N    | Puntaje obtenido en este partido   |

**GSI:** `MatchIdIndex` (hash_key: match_id) - permite consultar todas las apuestas de un partido.

### `score_user`
| Atributo    | Tipo | Descripción                    |
|-------------|------|--------------------------------|
| user_id     | S    | PK - ID del usuario            |
| total_score | N    | Puntaje acumulado total        |

---

## Flujo de Datos

### Flujo de Login
```
1. Frontend carga → GET /get_secret → Lambda get_secret → Secrets Manager
2. Recibe UserPoolId + ClientId → inicializa Cognito SDK
3. Usuario ingresa credenciales → Cognito SRP auth
4. Éxito → JWT almacenado en sessionStorage → UI según grupo
```

### Flujo de Apuesta
```
1. Usuario carga bets.html → GET /manage_matches → Lambda get_matches
2. Filtra partidos con status != FINISHED → muestra en dropdown
3. Usuario selecciona partido + resultado + marcador → POST /put_bets
4. Lambda put_bets → DynamoDB bets_users.put_item
```

### Flujo de Actualización de Resultado
```
1. Admin selecciona partido → POST /update_results
2. Lambda update_results:
   a. results_table.put_item (match_id, real_result, exact_score)
   b. matches_table.update_item (status = FINISHED)
3. DynamoDB Stream dispara Lambda recalculate_score
4. recalculate_score:
   a. Consulta bets_users via GSI MatchIdIndex
   b. Compara cada apuesta con resultado real
   c. Calcula nuevo puntaje (+3 resultado, +3 marcador exacto)
   d. Actualiza score_user.total_score (resta previo, suma nuevo)
   e. Actualiza bets_users.score por partido
```

---

## API Gateway - Endpoints

| Método | Ruta                              | Auth          | Lambda                          |
|--------|-----------------------------------|---------------|---------------------------------|
| GET    | /get_secret                       | NONE          | get_secret                      |
| POST   | /put_bets                         | COGNITO       | put_bets                        |
| GET    | /manage_matches                   | COGNITO       | get_matches                     |
| POST   | /manage_matches                   | COGNITO       | manage_matches                  |
| POST   | /create-matches-football-data     | COGNITO       | create_matches_for_futbol_data  |
| GET    | /update_results                   | COGNITO       | get_scores                      |
| POST   | /update_results                   | COGNITO       | update_results                  |
| OPTIONS| todos los anteriores              | NONE          | MOCK (CORS preflight)           |

---

## Seguridad

### Roles IAM (Cognito Identity Pool)
| Rol                  | Permisos Lambda                                              |
|----------------------|--------------------------------------------------------------|
| admin_role           | update_results, manage_matches, create_matches_for_futbol_data |
| general_role         | put_bets                                                     |
| authenticated_role   | Base (sin permisos Lambda directos)                          |
| unauthenticated_role | Sin permisos                                                 |

### Mapeo de Grupos Cognito → Roles
- `cognito:groups = admin` → `admin_role`
- `cognito:groups = general` → `general_role`
- Default autenticado → `general_role`

---

## Frontend - Páginas y Responsabilidades

| Página         | Rol     | Funcionalidad                                      |
|----------------|---------|----------------------------------------------------|
| index.html     | Todos   | Login + navegación post-login según grupo          |
| admin.html     | Admin   | Crear partido manual (match_id, teams, date)       |
| matches.html   | Admin   | Importar partidos desde football-data.org          |
| results.html   | Admin   | Actualizar resultado real de un partido            |
| bets.html      | General | Seleccionar partido y realizar apuesta             |
| score.html     | General | Ver ranking de puntajes ordenado                   |

### Configuración Dinámica
El archivo `config.js` es generado por Terraform con la URL del endpoint `get_secret`. El frontend lo usa para obtener en runtime todos los demás endpoints y credenciales de Cognito.

---

## Integración Externa: football-data.org

- La Lambda `create_matches_for_futbol_data` recibe `competition_id` y `matchday`.
- Obtiene el `X-Auth-Token` desde Secrets Manager en runtime.
- Llama a la API de football-data.org y almacena los partidos en `matches_table`.
