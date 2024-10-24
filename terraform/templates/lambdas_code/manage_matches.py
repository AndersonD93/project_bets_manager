import json
import boto3
import datetime
from botocore.exceptions import ClientError
import os

dynamodb = boto3.resource('dynamodb')
matches_table = dynamodb.Table(os.getenv('matches_table'))


def lambda_handler(event, context):
    match_id = event['match_id']
    teams = event['teams']
    match_date = event['match_date']
    
    try:
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
            'body': json.dumps
            (f'Partido {match_id} creado o actualizado exitosamente.')
        }
    
    except ClientError as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error: {str(e)}")
        }
