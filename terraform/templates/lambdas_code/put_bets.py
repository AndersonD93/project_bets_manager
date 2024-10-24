import json
import boto3
import datetime
from botocore.exceptions import ClientError
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('bets_users_table'))


def lambda_handler(event, context):
    user_id = event['user_id']
    match_id = event['match_id']
    bet_result = event['bet_result']
    exact_score = event['exact_score']
    
    try:
        # Guardar la apuesta en DynamoDB
        table.put_item(
            Item={
                'user_id': user_id,
                'match_id': match_id,
                'bet_result': bet_result,
                'exact_score': exact_score,
                'timestamp': str(datetime.datetime.now()),
                'modified': False  # Marcar que no ha sido modificada aún
            }
        )
        return {
            'statusCode': 200,
            'body': json.dumps('Apuesta registrada exitosamente.')
        }
    
    except ClientError as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error: {str(e)}")
        }
