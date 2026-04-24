import json
import boto3
from decimal import Decimal
from botocore.exceptions import ClientError
import os

dynamodb      = boto3.resource('dynamodb')
ssm           = boto3.client('ssm')
champion_table = dynamodb.Table(os.getenv('champion_table'))
score_table    = dynamodb.Table(os.getenv('score_table'))

BONUS_POINTS   = 15
SSM_WINNER_KEY = '/bets-manager/champion/tournament-winner'

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://d3iqu3owmhprm.cloudfront.net",
    "Content-Type": "application/json",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}


def get_current_winner():
    """Returns current tournament winner from SSM, or empty string if not set."""
    try:
        return ssm.get_parameter(Name=SSM_WINNER_KEY)['Parameter']['Value']
    except Exception:
        return ''


def set_winner_ssm(country):
    ssm.put_parameter(Name=SSM_WINNER_KEY, Value=country, Type='String', Overwrite=True)


def apply_bonus(country):
    """Add 15 pts to all users who picked this country. Sets champion_bonus_applied=True."""
    picks = champion_table.scan(
        FilterExpression='country = :c',
        ExpressionAttributeValues={':c': country}
    ).get('Items', [])

    for pick in picks:
        user_id = pick['user_id']
        try:
            score_table.update_item(
                Key={'user_id': user_id},
                UpdateExpression='ADD total_score :pts SET champion_bonus_applied = :flag',
                ExpressionAttributeValues={
                    ':pts':  Decimal(BONUS_POINTS),
                    ':flag': True
                }
            )
        except ClientError:
            pass

    return len(picks)


def remove_bonus():
    """Remove 15 pts from all users who have champion_bonus_applied=True."""
    response = score_table.scan(
        FilterExpression='champion_bonus_applied = :t',
        ExpressionAttributeValues={':t': True}
    )
    users = response.get('Items', [])

    for user in users:
        user_id = user['user_id']
        try:
            score_table.update_item(
                Key={'user_id': user_id},
                UpdateExpression='ADD total_score :pts SET champion_bonus_applied = :flag',
                ExpressionAttributeValues={
                    ':pts':  Decimal(-BONUS_POINTS),
                    ':flag': False
                }
            )
        except ClientError:
            pass

    return len(users)


def lambda_handler(event, context):
    if 'body' in event and event['body']:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
    else:
        return {'statusCode': 400, 'headers': CORS_HEADERS, 'body': json.dumps('Error: cuerpo vacío')}

    # country = '' means "unset winner"
    new_winner = body.get('country', '').strip()

    # Validate country if not empty
    if new_winner:
        try:
            countries_raw = ssm.get_parameter(Name='/bets-manager/world-cup-2026/countries')['Parameter']['Value']
            valid = [c.strip() for c in countries_raw.split(',')]
            if new_winner not in valid:
                return {'statusCode': 400, 'headers': CORS_HEADERS,
                        'body': json.dumps(f'País inválido: {new_winner}')}
        except Exception as e:
            return {'statusCode': 500, 'headers': CORS_HEADERS,
                    'body': json.dumps(f'Error validando país: {str(e)}')}

    current_winner = get_current_winner()

    # No change
    if new_winner == current_winner:
        return {'statusCode': 200, 'headers': CORS_HEADERS,
                'body': json.dumps(f'Sin cambios. Campeón actual: {current_winner or "sin seleccionar"}')}

    # Remove previous bonus if there was a winner
    removed = 0
    if current_winner:
        removed = remove_bonus()

    # Apply new bonus if setting a winner
    applied = 0
    if new_winner:
        applied = apply_bonus(new_winner)

    # Persist new winner in SSM
    set_winner_ssm(new_winner)

    msg = (
        f'Campeón actualizado a "{new_winner}". '
        f'+{BONUS_POINTS} pts aplicados a {applied} usuario(s).'
        if new_winner else
        f'Campeón removido. -{BONUS_POINTS} pts revertidos a {removed} usuario(s).'
    )

    return {'statusCode': 200, 'headers': CORS_HEADERS, 'body': json.dumps(msg)}
