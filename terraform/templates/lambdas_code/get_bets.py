import json
import boto3
from decimal import Decimal
import os

dynamodb      = boto3.resource('dynamodb')
bets_table    = dynamodb.Table(os.getenv('bets_users_table'))
matches_table = dynamodb.Table(os.getenv('matches_table'))

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://d3iqu3owmhprm.cloudfront.net",
    "Content-Type": "application/json",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}


def decimal_to_native(obj):
    if isinstance(obj, Decimal):
        return int(obj) if obj % 1 == 0 else float(obj)
    if isinstance(obj, dict):
        return {k: decimal_to_native(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [decimal_to_native(i) for i in obj]
    return obj


def lambda_handler(event, context):
    try:
        bets    = decimal_to_native(bets_table.scan().get('Items', []))
        matches = {m['match_id']: m for m in matches_table.scan().get('Items', [])}

        enriched = []
        for b in bets:
            match = matches.get(b.get('match_id', ''), {})
            enriched.append({
                'user_id':     b.get('user_id', ''),
                'match_id':    b.get('match_id', ''),
                'teams':       match.get('teams', b.get('match_id', '')),
                'bet_result':  b.get('bet_result', ''),
                'exact_score': b.get('exact_score', ''),
                'timestamp':   b.get('timestamp', ''),
            })

        # Sort by timestamp descending
        enriched.sort(key=lambda x: x.get('timestamp', ''), reverse=True)

        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps(enriched)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': CORS_HEADERS,
            'body': json.dumps({'error': str(e)})
        }
