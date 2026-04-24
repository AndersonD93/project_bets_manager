import json
import boto3
from decimal import Decimal
import os

dynamodb = boto3.resource('dynamodb')
results_table = dynamodb.Table(os.getenv('results_table'))
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
        results = decimal_to_native(results_table.scan().get('Items', []))
        matches = {m['match_id']: m for m in matches_table.scan().get('Items', [])}

        enriched = []
        for r in results:
            match = matches.get(r['match_id'], {})
            enriched.append({
                'match_id':    r['match_id'],
                'teams':       match.get('teams', r['match_id']),
                'real_result': r.get('real_result', ''),
                'exact_score': r.get('exact_score', ''),
                'updated_at':  r.get('updated_at', ''),
            })

        enriched.sort(key=lambda x: x.get('updated_at', ''), reverse=True)

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
