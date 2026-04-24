import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('matches_table'))

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://d3iqu3owmhprm.cloudfront.net",
    "Content-Type": "application/json",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}


def lambda_handler(event, context):
    try:
        # Admin can pass ?include_blocked=true to see all non-finished matches
        params = event.get('queryStringParameters') or {}
        include_blocked = params.get('include_blocked', 'false').lower() == 'true'

        response = table.scan()
        matches = response.get('Items', [])

        result = []
        for match in matches:
            status = match.get('status', '').strip().upper()
            if status == 'FINISHED':
                continue
            if status == 'BLOCKED' and not include_blocked:
                continue
            result.append({
                'match_id':   match['match_id'],
                'teams':      match['teams'],
                'match_date': match.get('match_date', ''),
                'status':     match.get('status', '')
            })

        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps(result)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': CORS_HEADERS,
            'body': json.dumps(str(e))
        }
