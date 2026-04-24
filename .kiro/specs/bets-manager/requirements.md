# Bets Manager - Requisitos

## Descripción General

Aplicación serverless de apuestas deportivas construida sobre AWS con Terraform como IaC. Permite a usuarios autenticados apostar en partidos de fútbol, mientras que administradores gestionan partidos y resultados. El sistema calcula puntajes automáticamente vía DynamoDB Streams.

## Actores

- **Admin**: Crea partidos manualmente o desde football-data.org, actualiza resultados reales.
- **General**: Realiza apuestas en partidos activos, consulta el ranking de puntajes.

---

## Requisitos Funcionales

### REQ-1: Autenticación y Autorización

- **REQ-1.1**: El sistema debe autenticar usuarios mediante AWS Cognito (User Pool con SRP auth).
- **REQ-1.2**: Los usuarios deben pertenecer a un grupo (`admin` o `general`) que determine sus permisos.
- **REQ-1.3**: Tras el login exitoso, el frontend debe almacenar el JWT token en `sessionStorage`.
- **REQ-1.4**: El frontend debe mostrar opciones de navegación según el grupo del usuario.
- **REQ-1.5**: El sistema debe soportar el flujo `newPasswordRequired` de Cognito para primer acceso.
- **REQ-1.6**: El endpoint `GET /get_secret` debe ser público (sin autenticación) para obtener la configuración inicial (UserPoolId, ClientId, URLs de API).

### REQ-2: Gestión de Partidos (Admin)

- **REQ-2.1**: Un admin debe poder crear partidos manualmente con `match_id`, `teams` y `match_date`.
- **REQ-2.2**: Un admin debe poder importar partidos desde la API de football-data.org especificando `competition_id` y `matchday`.
- **REQ-2.3**: Los partidos creados deben almacenarse en DynamoDB con estado inicial `SCHEDULED`.
- **REQ-2.4**: El sistema debe obtener el token de football-data.org desde AWS Secrets Manager en tiempo de ejecución.

### REQ-3: Apuestas (General)

- **REQ-3.1**: Un usuario general debe poder ver la lista de partidos con estado distinto a `FINISHED` y distinto a `BLOCKED`.
- **REQ-3.2**: Un usuario debe poder apostar el resultado de un partido (`home_win`, `away_win`, `draw`) y el marcador exacto (goles local y visitante).
- **REQ-3.3**: La apuesta debe registrarse en DynamoDB con `user_id`, `match_id`, `bet_result`, `exact_score` y `timestamp`.
- **REQ-3.4**: Una apuesta no modificada debe marcarse con `modified: false`.
- **REQ-3.5**: El sistema debe rechazar apuestas si el partido inicia en menos de 1 hora (basado en `match_date` de `matches_table`).
- **REQ-3.6**: El sistema debe rechazar apuestas si el partido tiene estado `BLOCKED`.

### REQ-7: Bloqueo de Apuestas por Partido (Admin)

- **REQ-7.1**: Un admin debe poder bloquear manualmente las apuestas de un partido desde el panel de administración.
- **REQ-7.2**: Al bloquear un partido, su estado debe cambiar a `BLOCKED` en `matches_table`.
- **REQ-7.3**: Un partido bloqueado no debe aparecer en la lista de partidos disponibles para apostar.
- **REQ-7.4**: Un admin debe poder desbloquear un partido (volver a estado `SCHEDULED`).

### REQ-8: Campeón del Torneo (General)

- **REQ-8.1**: Un usuario general debe poder seleccionar un país como su campeón del torneo desde un dropdown poblado desde SSM Parameter Store.
- **REQ-8.2**: Cada usuario puede tener un único campeón registrado (insert único + update permitido).
- **REQ-8.3**: El sistema debe rechazar la creación si el admin bloqueó el insert.
- **REQ-8.4**: El sistema debe rechazar la modificación si el admin bloqueó el update.
- **REQ-8.5**: El campeón seleccionado debe mostrarse en el dashboard del usuario con la bandera del país.

### REQ-9: Control de Campeón (Admin)

- **REQ-9.1**: El admin debe poder bloquear/desbloquear la creación de campeón (insert) para todos los usuarios.
- **REQ-9.2**: El admin debe poder bloquear/desbloquear la modificación de campeón (update) para todos los usuarios.
- **REQ-9.3**: Los controles de bloqueo deben estar en el panel de administración.

### REQ-10: Campeón Final del Torneo (Admin)

- **REQ-10.1**: El admin debe poder seleccionar el campeón final del torneo desde el mismo dropdown de países del Parameter Store.
- **REQ-10.2**: Al seleccionar el campeón final, el sistema debe evaluar la tabla `champion_picks` y sumar 15 puntos adicionales a cada usuario cuyo país coincida con el campeón seleccionado.
- **REQ-10.3**: La tabla `score_user` debe incluir una bandera `champion_bonus_applied` (`true`/`false`) para evitar doble suma.
- **REQ-10.4**: Si el admin revierte la selección (estado "sin seleccionar"), el sistema debe restar los 15 puntos a los usuarios que los recibieron y poner la bandera en `false`.
- **REQ-10.5**: El campeón final seleccionado debe almacenarse en SSM Parameter Store para persistencia.
- **REQ-10.6**: La lógica de recálculo debe estar en una función dentro de `recalculate_score` o en una Lambda dedicada invocada desde el frontend del admin.

- **REQ-4.1**: Un admin debe poder actualizar el resultado real de un partido con `match_id`, `real_result` y `exact_score`.
- **REQ-4.2**: Al actualizar el resultado, el partido debe marcarse como `FINISHED` en la tabla de partidos.
- **REQ-4.3**: El resultado real debe almacenarse en la tabla `results_table`.

### REQ-5: Cálculo Automático de Puntajes

- **REQ-5.1**: Cuando se inserte o modifique un registro en `results_table`, DynamoDB Streams debe disparar la Lambda `recalculate_score`.
- **REQ-5.2**: La Lambda debe comparar cada apuesta del partido con el resultado real.
- **REQ-5.3**: Reglas de puntuación:
  - +3 puntos si el resultado apostado coincide con el resultado real.
  - +3 puntos adicionales si el marcador exacto apostado coincide con el marcador real.
- **REQ-5.4**: El puntaje total del usuario debe actualizarse en la tabla `score_user` de forma incremental (restando puntaje previo y sumando el nuevo).

### REQ-6: Ranking de Puntajes

- **REQ-6.1**: Cualquier usuario autenticado debe poder consultar el ranking de puntajes.
- **REQ-6.2**: El ranking debe mostrar todos los usuarios ordenados de mayor a menor puntaje.
- **REQ-6.3**: El ranking debe mostrar `user_id` y `total_score`.

---

## Requisitos No Funcionales

### REQ-NF-1: Infraestructura como Código
- Toda la infraestructura debe estar definida en Terraform con módulos reutilizables.
- El estado de Terraform debe poder almacenarse localmente (desarrollo) o en S3 + DynamoDB (producción).

### REQ-NF-2: Seguridad
- Todos los endpoints protegidos deben validar el JWT de Cognito via API Gateway Authorizer.
- Los secretos (tokens de API, IDs de Cognito) deben almacenarse en AWS Secrets Manager.
- Las políticas IAM deben seguir el principio de mínimo privilegio.
- CORS debe restringirse al origen del bucket S3 del frontend.

### REQ-NF-3: Escalabilidad y Disponibilidad
- Las Lambdas deben ser stateless y usar Python 3.12.
- DynamoDB debe usar billing on-demand (pay-per-request).
- El frontend debe estar alojado en S3 y distribuido via CloudFront con HTTPS.

### REQ-NF-6: Frontend React
- El frontend debe estar implementado en React + Vite.
- El routing debe ser client-side con React Router v6.
- La autenticación Cognito debe manejarse con `amazon-cognito-identity-js`.
- El build de producción se genera con `npm run build` y se sube al bucket S3.
- CloudFront debe redirigir HTTP a HTTPS y servir `index.html` para rutas SPA (403/404 → 200).

### REQ-NF-4: Observabilidad
- Las Lambdas deben registrar logs en CloudWatch.
- Los errores deben retornar códigos HTTP apropiados (400, 500) con mensajes descriptivos.

### REQ-NF-5: CORS
- Todas las respuestas Lambda deben incluir headers CORS (`Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, `Access-Control-Allow-Headers`).
- Cada endpoint debe tener un método OPTIONS con integración MOCK que retorne 200.
