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
    secret_name = 'project/appConfig'
    region_name = 'us-east-1'

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
    created_at = datetime.now().strftime('%Y-%m-%dT%H:%M:%SZ')
    
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


def lambda_handler(event, context):
    competition_id = event.get('competition_id')
    matchday = event.get('matchday')   
    
    if not competition_id:
        return {"statusCode": 400, "body": "Missing competition_id"}

    # Obtener el token de autenticación
    x_auth_token = get_secret()

    api_url = f"https://api.football-data.org/v4/competitions/{competition_id}/matches?matchday={matchday}"
    headers = {'X-Auth-Token': x_auth_token}
    
    # Preparar la solicitud con urllib
    req = urllib.request.Request(api_url, headers=headers)
    
    try:
        with urllib.request.urlopen(req) as response:
            response_body = response.read().decode('utf-8')
            matches = json.loads(response_body).get('matches', [])
    except urllib.error.URLError as e:
        print(f"Error fetching data from football-data API: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error fetching data from API')
        }

    # Guardar cada partido en DynamoDB
    for match in matches:
        save_match_to_dynamodb(match)

    return {
        'statusCode': 200,
        'body': json.dumps
        (f'Successfully saved {len(matches)} matches to DynamoDB')
    }
