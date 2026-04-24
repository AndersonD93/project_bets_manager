import json
import boto3
import datetime
from botocore.exceptions import ClientError
import os

dynamodb = boto3.resource('dynamodb')
matches_table = dynamodb.Table(os.getenv('matches_table'))

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://d3iqu3owmhprm.cloudfront.net",
    "Content-Type": "application/json",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}

ALLOWED_STATUSES = {'BLOCKED', 'SCHEDULED'}


def lambda_handler(event, context):
    if 'body' in event and event['body']:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
    else:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps('Error: cuerpo vacío')}

    try:
        match_id   = body['match_id']
        new_status = body['status'].upper()
    except KeyError as e:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error: falta el campo {str(e)}')}

    if new_status not in ALLOWED_STATUSES:
        return {
            'statusCode': 400,
            'headers': CORS_HEADERS,
            'body': json.dumps(f'Estado inválido. Valores permitidos: {", ".join(ALLOWED_STATUSES)}')
        }

    try:
        # Verify match exists and is not FINISHED
        resp = matches_table.get_item(Key={'match_id': match_id})
        match = resp.get('Item')
        if not match:
            return {'statusCode': 404, 'headers': CORS_HEADERS, 'body': json.dumps('Partido no encontrado')}

        if match.get('status', '').upper() == 'FINISHED':
            return {
                'statusCode': 403,
                'headers': CORS_HEADERS,
                'body': json.dumps('No se puede cambiar el estado de un partido finalizado.')
            }

        matches_table.update_item(
            Key={'match_id': match_id},
            UpdateExpression='SET #s = :status, updated_at = :updated_at',
            ExpressionAttributeNames={'#s': 'status'},
            ExpressionAttributeValues={
                ':status': new_status,
                ':updated_at': str(datetime.datetime.now(datetime.timezone.utc))
            }
        )

        action = 'bloqueado' if new_status == 'BLOCKED' else 'desbloqueado'
        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps(f'Partido {match_id} {action} exitosamente.')
        }

    except ClientError as e:
        return {'statusCode': 500, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error: {str(e)}')}
