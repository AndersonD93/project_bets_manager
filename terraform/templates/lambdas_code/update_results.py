import json
import boto3
import datetime
import os
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
results_table = dynamodb.Table(os.getenv('results_table'))
matches_table = dynamodb.Table(os.getenv('matches_table'))


def lambda_handler(event, context):
    match_id = event['match_id']
    real_result = event['real_result']
    exact_score = event['exact_score']
    
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
            'body': json.dumps('Resultado actualizado exitosamente.')
        }
    
    except ClientError as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error: {str(e)}")
        }
