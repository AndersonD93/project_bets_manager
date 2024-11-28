import json
import boto3
import urllib.request
from datetime import datetime
from botocore.exceptions import ClientError
import os

# Inicializa los clientes de DynamoDB y Secrets Manager
dynamodb = boto3.resource('dynamodb')
secrets_manager = boto3.client('secretsmanager', region_name='us-east-1')

# Nombre de la tabla DynamoDB
TABLE_NAME = os.getenv('matches_table')

def get_secret():
    secret_name = os.getenv('secret_name')
    region_name = os.getenv('region_name')

    client = boto3.client('secretsmanager', region_name=region_name)

    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = response['SecretString']
        secret_dict = json.loads(secret)
        x_auth_token = secret_dict['X-Auth-Token']
        return x_auth_token
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        raise e

def save_match_to_dynamodb(match):
    table = dynamodb.Table(TABLE_NAME)
    
    match_id = match['id']
    match_date = match['utcDate']
    home_team = match['homeTeam']['shortName']
    away_team = match['awayTeam']['shortName']
    status = match['status']
    
    # Construir el estado concatenando homeTeam vs awayTeam
    teams = f"{home_team} vs {away_team}"
    
    # Obtener la fecha actual
    created_at = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
    
    # Crear el objeto a insertar
    item = {
        'match_id': str(match_id),
        'created_at': created_at,
        'match_date': match_date,
        'status': status,
        'teams': teams
    }
    
    try:
        table.put_item(Item=item)
        print(f"Match {match_id} saved successfully.")
    except ClientError as e:
        print(f"Error saving match {match_id} to DynamoDB: {e}")
        raise e

def add_cors_headers(response):
    """
    Añade los encabezados necesarios para evitar errores de CORS.
    """
    response['headers'] = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization"
    }
    return response

def lambda_handler(event, context):
    print(f"event:{event}")

    # Verifica si el cuerpo de la solicitud existe y no es None
    if not event.get("body"):
        return add_cors_headers({"statusCode": 400, "body": json.dumps({"message": "Missing request body"})})

    try:
        # Deserializa el cuerpo de la solicitud
        body = json.loads(event["body"])
    except json.JSONDecodeError:
        return add_cors_headers({"statusCode": 400, "body": json.dumps({"message": "Invalid JSON format"})})
    
    # Extrae los valores necesarios del cuerpo
    competition_id = body.get('competition_id')
    matchday = body.get('matchday')

    # Valida que los parámetros estén presentes
    if not competition_id or not matchday:
        return add_cors_headers({
            "statusCode": 400,
            "body": json.dumps({"message": "Missing competition_id or matchday"})
        })

    # Obtener el token de autenticación
    try:
        x_auth_token = get_secret()
    except Exception as e:
        return add_cors_headers({
            'statusCode': 500,
            'body': json.dumps({"message": "Error retrieving authentication token", "error": str(e)})
        })

    # Construir la URL de la API
    api_url = f"https://api.football-data.org/v4/competitions/{competition_id}/matches?matchday={matchday}"
    headers = {'X-Auth-Token': x_auth_token}
    
    # Realizar la solicitud a la API
    try:
        req = urllib.request.Request(api_url, headers=headers)
        with urllib.request.urlopen(req) as response:
            response_body = response.read().decode('utf-8')
            matches = json.loads(response_body).get('matches', [])
    except urllib.error.URLError as e:
        print(f"Error fetching data from football-data API: {e}")
        return add_cors_headers({
            'statusCode': 500,
            'body': json.dumps({"message": "Error fetching data from API", "error": str(e)})
        })

    # Guardar cada partido en DynamoDB
    try:
        for match in matches:
            save_match_to_dynamodb(match)
    except Exception as e:
        return add_cors_headers({
            'statusCode': 500,
            'body': json.dumps({"message": "Error saving matches to DynamoDB", "error": str(e)})
        })

    return add_cors_headers({
        'statusCode': 200,
        'body': json.dumps({"message": f"Successfully saved {len(matches)} matches to DynamoDB"})
    })
