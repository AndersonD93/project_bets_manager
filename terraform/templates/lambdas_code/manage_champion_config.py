import json
import boto3
from botocore.exceptions import ClientError
import os

ssm = boto3.client('ssm')

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://d3iqu3owmhprm.cloudfront.net",
    "Content-Type": "application/json",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}

ALLOWED_PARAMS = {
    'insert_blocked': '/bets-manager/champion/insert-blocked',
    'update_blocked': '/bets-manager/champion/update-blocked',
}


def lambda_handler(event, context):
    if 'body' in event and event['body']:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
    else:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps('Error: cuerpo vacío')}

    updates = {}
    for key, param_name in ALLOWED_PARAMS.items():
        if key in body:
            value = str(body[key]).lower()
            if value not in ('true', 'false'):
                return {'statusCode': 400, 'headers': CORS_HEADERS,
                        'body': json.dumps(f'Valor inválido para {key}: debe ser true o false')}
            updates[param_name] = value

    if not updates:
        return {'statusCode': 400, 'headers': CORS_HEADERS,
                'body': json.dumps('No se proporcionaron parámetros válidos')}

    try:
        for param_name, value in updates.items():
            ssm.put_parameter(Name=param_name, Value=value, Type='String', Overwrite=True)

        return {'statusCode': 200, 'headers': CORS_HEADERS,
                'body': json.dumps('Configuración actualizada exitosamente')}
    except ClientError as e:
        return {'statusCode': 500, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error: {str(e)}')}
