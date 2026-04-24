import json
import boto3
import datetime
from botocore.exceptions import ClientError
import os

dynamodb = boto3.resource('dynamodb')
ssm      = boto3.client('ssm')
table    = dynamodb.Table(os.getenv('champion_table'))

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://d3iqu3owmhprm.cloudfront.net",
    "Content-Type": "application/json",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}


def get_ssm(name):
    return ssm.get_parameter(Name=name)['Parameter']['Value']


def lambda_handler(event, context):
    if 'body' in event and event['body']:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
    else:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps('Error: cuerpo vacío')}

    try:
        user_id = body['user_id']
        country = body['country']
    except KeyError as e:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error: falta {str(e)}')}

    # Check if user already has a champion (insert vs update)
    try:
        existing = table.get_item(Key={'user_id': user_id}).get('Item')
    except ClientError as e:
        return {'statusCode': 500, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error: {str(e)}')}

    is_update = existing is not None

    # Check admin blocks via SSM
    try:
        if not is_update:
            insert_blocked = get_ssm('/bets-manager/champion/insert-blocked').lower() == 'true'
            if insert_blocked:
                return {'statusCode': 403, 'headers': CORS_HEADERS,
                        'body': json.dumps('El registro de campeón está bloqueado por el administrador.')}
        else:
            update_blocked = get_ssm('/bets-manager/champion/update-blocked').lower() == 'true'
            if update_blocked:
                return {'statusCode': 403, 'headers': CORS_HEADERS,
                        'body': json.dumps('La modificación de campeón está bloqueada por el administrador.')}
    except Exception as e:
        return {'statusCode': 500, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error SSM: {str(e)}')}

    # Validate country against SSM list
    try:
        countries_raw = get_ssm('/bets-manager/world-cup-2026/countries')
        valid_countries = [c.strip() for c in countries_raw.split(',')]
        if country not in valid_countries:
            return {'statusCode': 400, 'headers': CORS_HEADERS,
                    'body': json.dumps(f'País inválido: {country}')}
    except Exception as e:
        return {'statusCode': 500, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error validando país: {str(e)}')}

    # Save
    try:
        table.put_item(Item={
            'user_id':    user_id,
            'country':    country,
            'updated_at': str(datetime.datetime.now(datetime.timezone.utc))
        })
        action = 'actualizado' if is_update else 'registrado'
        return {'statusCode': 200, 'headers': CORS_HEADERS,
                'body': json.dumps(f'Campeón {action} exitosamente: {country}')}
    except ClientError as e:
        return {'statusCode': 500, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error: {str(e)}')}
