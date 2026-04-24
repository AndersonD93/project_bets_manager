import json
import boto3
import datetime
from botocore.exceptions import ClientError
from dateutil import parser as date_parser
import os

dynamodb = boto3.resource('dynamodb')
bets_table    = dynamodb.Table(os.getenv('bets_users_table'))
matches_table = dynamodb.Table(os.getenv('matches_table'))

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://d3iqu3owmhprm.cloudfront.net",
    "Content-Type": "application/json",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}

def lambda_handler(event, context):
    # Parse body
    if 'body' in event and event['body']:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
    else:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps('Error: cuerpo vacío')}

    try:
        user_id     = body['user_id']
        match_id    = body['match_id']
        bet_result  = body['bet_result']
        exact_score = body['exact_score']
    except KeyError as e:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error: falta el campo {str(e)}')}

    # Validate match exists and betting is allowed
    try:
        match_resp = matches_table.get_item(Key={'match_id': match_id})
        match = match_resp.get('Item')

        if not match:
            return {'statusCode': 404, 'headers': CORS_HEADERS, 'body': json.dumps('Error: partido no encontrado')}

        status = match.get('status', '').strip().upper()

        # Block if match is manually blocked
        if status == 'BLOCKED':
            return {
                'statusCode': 403,
                'headers': CORS_HEADERS,
                'body': json.dumps('Las apuestas para este partido han sido bloqueadas por el administrador.')
            }

        # Block if match already finished
        if status == 'FINISHED':
            return {
                'statusCode': 403,
                'headers': CORS_HEADERS,
                'body': json.dumps('El partido ya ha finalizado. No se pueden realizar apuestas.')
            }

        # Block if match starts within 1 hour
        match_date_str = match.get('match_date')
        if match_date_str:
            try:
                match_dt = date_parser.parse(match_date_str)
                # Make timezone-aware if naive
                if match_dt.tzinfo is None:
                    match_dt = match_dt.replace(tzinfo=datetime.timezone.utc)
                now = datetime.datetime.now(datetime.timezone.utc)
                time_until_match = (match_dt - now).total_seconds()

                if time_until_match <= 3600:  # 1 hour = 3600 seconds
                    minutes_left = max(0, int(time_until_match / 60))
                    return {
                        'statusCode': 403,
                        'headers': CORS_HEADERS,
                        'body': json.dumps(
                            f'No se pueden realizar apuestas. El partido inicia en {minutes_left} minutos '
                            f'(mínimo 1 hora de anticipación requerida).'
                        )
                    }
            except Exception:
                pass  # If date can't be parsed, allow the bet

    except ClientError as e:
        return {'statusCode': 500, 'headers': CORS_HEADERS, 'body': json.dumps(f'Error al validar partido: {str(e)}')}

    # Save bet
    try:
        bets_table.put_item(
            Item={
                'user_id': user_id,
                'match_id': match_id,
                'bet_result': bet_result,
                'exact_score': exact_score,
                'timestamp': str(datetime.datetime.now(datetime.timezone.utc)),
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
