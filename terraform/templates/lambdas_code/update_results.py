import json
import boto3
import datetime
import os
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
results_table = dynamodb.Table(os.getenv('results_table'))
matches_table = dynamodb.Table(os.getenv('matches_table'))


def lambda_handler(event, context):
    if 'body' in event and event['body']:
        body = json.loads(event['body'])
    else:
        return {
            "statusCode": 400,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
            "body": "Error: No se encontró el cuerpo de la solicitud."
        }
    try:
        match_id = body['match_id']
        real_result = body['real_result']
        exact_score = body['exact_score']
    except KeyError as e:
        return {
            "statusCode": 400,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
            "body": f"Error: Falta la clave {str(e)} en el cuerpo de la solicitud."
        }    
    
    try:
        # Actualizar el resultado real en DynamoDB
        results_table.put_item(
            Item={
                'match_id': match_id,
                'real_result': real_result,
                'exact_score': exact_score,
                'updated_at': str(datetime.datetime.now())
            }
        )
        matches_table.update_item(
            Key={
                'match_id': match_id
            },
            UpdateExpression="SET #status = :status, updated_at = :updated_at",
            ExpressionAttributeNames={
                '#status': 'status'
            },
            ExpressionAttributeValues={
                ':status': 'FINISHED',
                ':updated_at': str(datetime.datetime.now())
            },
            ReturnValues="UPDATED_NEW"
        )
        return {
            'statusCode': 200,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
            'body': json.dumps('Resultado actualizado exitosamente. ')
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
