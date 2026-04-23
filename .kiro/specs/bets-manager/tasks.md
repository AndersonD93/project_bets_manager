# Bets Manager - Tareas de Implementación

## Estado de Tareas

- [ ] = Pendiente
- [x] = Completado
- [~] = En progreso

---

## Fase 1: Infraestructura Base

### TASK-1: Módulo tf-state (Backend Remoto)
- [ ] Crear bucket S3 para almacenar el estado de Terraform
- [ ] Crear tabla DynamoDB para state locking
- [ ] Verificar que el módulo acepta `bucket_name` como variable
- **Archivos**: `terraform/modules/tf-state/`

### TASK-2: Módulo DynamoDB
- [ ] Implementar módulo genérico que acepte un mapa de tablas (`dynamo_tables`)
- [ ] Soportar hash_key, range_key, atributos, GSI y DynamoDB Streams
- [ ] Exponer outputs: `dynamo_table_name`, `dynamo_table_arn`, `dynamo_table_stream_arn`, `global_secondary_index_names`
- [ ] Implementar sub-módulo `dynamo_permission` para adjuntar políticas IAM a roles Lambda
- **Archivos**: `terraform/modules/resources/dynamo_table/`

### TASK-3: Módulo Lambda
- [ ] Implementar módulo genérico que acepte un mapa de funciones (`lambda_map`)
- [ ] Crear rol de ejecución IAM por Lambda con política básica de logs CloudWatch
- [ ] Soportar variables de entorno por función
- [ ] Exponer outputs: `invoke_arn`, `lambda_arns`, `lambda_name`, `lambda_role_arns`
- [ ] Implementar sub-módulo `lambda_permission` para permisos de invocación desde API Gateway
- **Archivos**: `terraform/modules/resources/lambda/`

### TASK-4: Módulo API Gateway
- [ ] Crear REST API regional con nombre y descripción configurables
- [ ] Crear recursos (path parts) a partir de una lista
- [ ] Exponer outputs: `api_id`, `api_root_resource_id`, `api_resource_ids`
- [ ] Implementar sub-módulo `api_resources` para métodos HTTP (GET, POST, OPTIONS)
- [ ] Soportar integraciones `AWS_PROXY` y `MOCK`
- [ ] Soportar autorización `COGNITO_USER_POOLS` y `NONE`
- [ ] Exponer outputs: `url_invoke_api`, `method_arn`
- **Archivos**: `terraform/modules/resources/api_gateway/`

---

## Fase 2: Lambdas Backend

### TASK-5: Lambda `get_secret`
- [ ] Leer secreto `project/app-bets-manager` desde Secrets Manager
- [ ] Retornar el secreto completo como JSON (UserPoolId, ClientId, URLs de API)
- [ ] No requiere autenticación (endpoint público)
- **Archivo**: `terraform/templates/lambdas_code/get_secret.py`

### TASK-6: Lambda `manage_matches`
- [ ] Recibir `match_id`, `teams`, `match_date` desde el body
- [ ] Insertar partido en `matches_table` con status `SCHEDULED`
- [ ] Retornar 200 en éxito, 400 en error
- **Archivo**: `terraform/templates/lambdas_code/manage_matches.py`

### TASK-7: Lambda `get_matches`
- [ ] Escanear `matches_table`
- [ ] Filtrar partidos con status distinto a `FINISHED`
- [ ] Retornar lista con `match_id`, `teams`, `status`
- **Archivo**: `terraform/templates/lambdas_code/get_matches.py`

### TASK-8: Lambda `create_matches_for_futbol_data`
- [ ] Recibir `competition_id` y `matchday`
- [ ] Obtener `X-Auth-Token` desde Secrets Manager
- [ ] Llamar a la API de football-data.org
- [ ] Almacenar partidos en `matches_table`
- **Archivo**: `terraform/templates/lambdas_code/create_matches_for_futbol_data.py`

### TASK-9: Lambda `put_bets`
- [ ] Recibir `user_id`, `match_id`, `bet_result`, `exact_score`
- [ ] Insertar apuesta en `bets_users` con timestamp y `modified: false`
- [ ] Retornar 200 en éxito, 400 en error
- **Archivo**: `terraform/templates/lambdas_code/put_bets.py`

### TASK-10: Lambda `update_results`
- [ ] Recibir `match_id`, `real_result`, `exact_score`
- [ ] Insertar resultado en `results_table`
- [ ] Actualizar `matches_table` con status `FINISHED`
- [ ] Retornar 200 en éxito, 400 en error
- **Archivo**: `terraform/templates/lambdas_code/update_results.py`

### TASK-11: Lambda `get_scores`
- [ ] Escanear `score_user` table
- [ ] Ordenar por `total_score` descendente
- [ ] Convertir tipos Decimal a int/float para serialización JSON
- [ ] Retornar lista ordenada o mensaje si no hay puntajes
- **Archivo**: `terraform/templates/lambdas_code/get_scores.py`

### TASK-12: Lambda `recalculate_score`
- [ ] Procesar eventos de DynamoDB Streams (INSERT y MODIFY)
- [ ] Extraer `match_id`, `real_result`, `exact_score` del evento
- [ ] Consultar todas las apuestas del partido via GSI `MatchIdIndex`
- [ ] Calcular puntaje: +3 por resultado correcto, +3 por marcador exacto
- [ ] Actualizar `score_user.total_score` (restar previo, sumar nuevo)
- [ ] Actualizar `bets_users.score` por partido
- **Archivo**: `terraform/templates/lambdas_code/recalculate_score.py`

---

## Fase 3: Infraestructura AWS

### TASK-13: Cognito
- [ ] Crear User Pool `bets-user-pool` con email auto-verificado
- [ ] Crear grupos `admin` y `general`
- [ ] Crear App Client `app-bets-manager` (sin secret, SRP + refresh token)
- [ ] Crear Identity Pool `bets-identity-pool` (sin identidades no autenticadas)
- [ ] Configurar role mapping: admin → admin_role, general → general_role
- **Archivo**: `terraform/cognito.tf`

### TASK-14: IAM Roles
- [ ] Crear `admin_role` con permisos para invocar update_results, manage_matches, create_matches_for_futbol_data
- [ ] Crear `general_role` con permisos para invocar put_bets
- [ ] Crear `authenticated_role` y `unauthenticated_role` base
- [ ] Todos los roles deben asumir identidad via Cognito Identity Pool
- **Archivo**: `terraform/iam.tf`

### TASK-15: Secrets Manager
- [ ] Referenciar secreto existente `project/footbal-data` (X-Auth-Token)
- [ ] Crear secreto `project/app-bets-manager` con URLs de API, UserPoolId, ClientId
- [ ] El secreto de la app debe construirse con outputs de otros módulos
- **Archivo**: `terraform/secret_manager.tf`

### TASK-16: DynamoDB Tables (Root)
- [ ] Instanciar módulo `dynamo_table` con las 4 tablas: `score_user`, `results_table`, `matches_table`, `bets_users`
- [ ] Habilitar DynamoDB Streams en `results_table` (NEW_AND_OLD_IMAGES)
- [ ] Configurar GSI `MatchIdIndex` en `bets_users`
- [ ] Configurar permisos de acceso por Lambda
- **Archivo**: `terraform/dynamo.tf`

### TASK-17: Lambdas (Root)
- [ ] Instanciar módulo `lambda` con las 8 funciones
- [ ] Configurar variables de entorno por función (nombres de tablas, secretos)
- [ ] Configurar permisos de invocación desde API Gateway
- [ ] Configurar DynamoDB Stream trigger para `recalculate_score` (batch_size: 100, LATEST)
- **Archivo**: `terraform/lambda.tf`

### TASK-18: API Gateway (Root)
- [ ] Instanciar módulo `api_gateway` con los 5 path parts
- [ ] Crear Cognito Authorizer referenciando el User Pool
- [ ] Configurar módulos `api_resources` para cada endpoint con métodos OPTIONS + HTTP
- [ ] Generar `config.js` dinámicamente con la URL del endpoint `get_secret`
- **Archivo**: `terraform/api_gateway.tf`

### TASK-19: S3 Frontend
- [ ] Crear bucket S3 para hosting estático del frontend
- [ ] Configurar bucket como sitio web estático
- [ ] Subir archivos HTML, CSS, JS y `config.js` generado
- **Archivo**: `terraform/modules/resources/s3.tf`

---

## Fase 4: Frontend

### TASK-20: Página de Login (`index.html` + `login.js`)
- [ ] Formulario de login (username, password)
- [ ] Integración con Cognito SDK (amazon-cognito-identity-js)
- [ ] Obtener UserPoolId y ClientId desde `GET /get_secret`
- [ ] Almacenar JWT en sessionStorage tras login exitoso
- [ ] Mostrar opciones según grupo (admin/general)
- [ ] Manejar flujo `newPasswordRequired`
- **Archivos**: `terraform/templates/index.html`, `terraform/templates/js/login.js`

### TASK-21: Panel Admin - Crear Partido (`admin.html` + `admin.js`)
- [ ] Formulario con campos match_id, teams, match_date
- [ ] Llamar `POST /manage_matches` con JWT en header Authorization
- [ ] Mostrar confirmación o error
- **Archivos**: `terraform/templates/html/admin.html`, `terraform/templates/js/admin.js`

### TASK-22: Panel Admin - Importar Partidos (`matches.html` + `matches.js`)
- [ ] Formulario con competition_id y matchday
- [ ] Llamar `POST /create-matches-football-data` con JWT
- [ ] Mostrar resultado de la importación
- **Archivos**: `terraform/templates/html/matches.html`, `terraform/templates/js/matches.js`

### TASK-23: Panel Admin - Actualizar Resultados (`results.html` + `results.js`)
- [ ] Cargar lista de partidos desde `GET /manage_matches`
- [ ] Formulario para seleccionar partido, resultado real y marcador exacto
- [ ] Llamar `POST /update_results` con JWT
- [ ] Mostrar confirmación o error
- **Archivos**: `terraform/templates/html/results.html`, `terraform/templates/js/results.js`

### TASK-24: Panel General - Realizar Apuesta (`bets.html` + `bets.js`)
- [ ] Cargar partidos activos desde `GET /manage_matches`
- [ ] Dropdown de partidos, selector de resultado, inputs de goles
- [ ] Llamar `POST /put_bets` con JWT
- [ ] Mostrar confirmación o error
- **Archivos**: `terraform/templates/html/bets.html`, `terraform/templates/js/bets.js`

### TASK-25: Panel General - Ver Puntajes (`score.html` + `score.js`)
- [ ] Llamar `GET /update_results` (endpoint get_scores) con JWT
- [ ] Mostrar tabla con ranking: posición, usuario, puntaje
- [ ] Ordenar de mayor a menor
- **Archivos**: `terraform/templates/html/score.html`, `terraform/templates/js/score.js`

### TASK-26: Utilidades Compartidas (`function.js`)
- [ ] `getPoolData(apiUrl)` - Fetch GET sin auth para obtener config
- [ ] `login(userPool)` - Autenticación Cognito SRP
- [ ] `logout()` - Limpiar sessionStorage y redirigir
- [ ] `fetchMatches(url)` - GET partidos con JWT
- [ ] `placeBet(url, match_id, bet_result, exact_score)` - POST apuesta con JWT
- [ ] `updateResult(url, match_id, real_result, exact_score)` - POST resultado con JWT
- [ ] `fetchScores(url)` - GET puntajes con JWT
- [ ] `displayScores(scores)` - Renderizar tabla de ranking
- [ ] `createMatch(url)` - POST crear partido con JWT
- [ ] `fetchCreateMatches(url, competitionId, matchday)` - POST importar partidos con JWT
- **Archivo**: `terraform/templates/js/function.js`

---

## Fase 5: Configuración y Despliegue

### TASK-27: Variables y Locals
- [ ] Definir variables: `region`, `project`
- [ ] Definir locals: listas de nombres de S3 buckets y tablas DynamoDB
- [ ] Crear `terraform.tfvars` con valores por defecto
- **Archivos**: `terraform/variables.tf`, `terraform/locals.tf`, `terraform/terraform.tfvars`

### TASK-28: Outputs
- [ ] Exponer URL del frontend (S3 website URL)
- [ ] Exponer endpoint base de API Gateway
- [ ] Exponer IDs de Cognito User Pool y App Client
- **Archivo**: `terraform/output.tf`

### TASK-29: Empaquetado de Lambdas
- [ ] Generar archivos `.zip` para cada Lambda desde los `.py` correspondientes
- [ ] Nombrar los zips con hash del contenido para forzar actualizaciones en Terraform
- [ ] Verificar que el módulo Lambda referencia los zips correctos
- **Directorio**: `terraform/templates/lambdas_code/`

### TASK-30: Validación End-to-End
- [ ] Ejecutar `terraform init` con backend local
- [ ] Ejecutar `terraform plan` y verificar que no hay errores
- [ ] Ejecutar `terraform apply` y verificar recursos creados
- [ ] Probar login con usuario admin y general
- [ ] Probar flujo completo: crear partido → apostar → actualizar resultado → ver puntaje
- [ ] Verificar que DynamoDB Stream dispara `recalculate_score` correctamente
