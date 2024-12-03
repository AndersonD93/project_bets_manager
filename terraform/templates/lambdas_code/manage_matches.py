import json
import boto3
import datetime
from botocore.exceptions import ClientError
import os

dynamodb = boto3.resource('dynamodb')
matches_table = dynamodb.Table(os.getenv('matches_table'))


def lambda_handler(event, context):
    try:
        if 'body' in event:
            body = json.loads(event['body'])  # Decodifica el JSON del cuerpo
        else:
            raise KeyError("No se encontró el cuerpo de la solicitud.")
        
        # Extraer los valores necesarios
        match_id = body['match_id']
        teams = body['teams']
        match_date = body['match_date']
        
        # Crear o actualizar el partido en DynamoDB
        matches_table.put_item(
            Item={
                'match_id': match_id,
                'teams': teams,
                'match_date': match_date,
                'created_at': str(datetime.datetime.now()),
                'status': 'scheduled'  # Estado inicial del partido
            }
        )
        return {
            'statusCode': 200,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
            'body': json.dumps(f'Partido {match_id} creado o actualizado exitosamente.')
        }
    
    except KeyError as e:
        return {
            'statusCode': 400,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
            'body': json.dumps(f"Error: Falta la clave {str(e)} en el cuerpo de la solicitud.")
        }
    
    except ClientError as e:
        return {
            'statusCode': 400,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
            'body': json.dumps(f"Error: {str(e)}")
        }