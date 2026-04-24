import json
import boto3
import datetime
from botocore.exceptions import ClientError
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('bets_users_table'))

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://d3iqu3owmhprm.cloudfront.net",
    "Content-Type": "application/json",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}


def lambda_handler(event, context):
    # API Gateway AWS_PROXY wraps body as string
    if 'body' in event and event['body']:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
    else:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps('Error: cuerpo vacío')}

    try:
        user_id    = body['user_id']
        match_id   = body['match_id']
        bet_result = body['bet_result']
        exact_score = body['exact_score']
    except KeyError as e:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error: falta el campo {str(e)}')}

    try:
        table.put_item(
            Item={
                'user_id': user_id,
                'match_id': match_id,
                'bet_result': bet_result,
                'exact_score': exact_score,
                'timestamp': str(datetime.datetime.now()),
                'modified': False
            }
        )
        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps('Apuesta registrada exitosamente.')
        }

    except ClientError as e:
        return {
            'statusCode': 400,
            'headers': CORS_HEADERS,
            'body': json.dumps(f'Error: {str(e)}')
        }
