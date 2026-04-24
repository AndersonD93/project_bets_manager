import json
import boto3
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


def lambda_handler(event, context):
    params = event.get('queryStringParameters') or {}
    user_id = params.get('user_id')

    try:
        # Get countries list
        countries_raw = ssm.get_parameter(Name='/bets-manager/world-cup-2026/countries')['Parameter']['Value']
        countries = sorted([c.strip() for c in countries_raw.split(',')])

        # Get block status
        insert_blocked = ssm.get_parameter(Name='/bets-manager/champion/insert-blocked')['Parameter']['Value'].lower() == 'true'
        update_blocked = ssm.get_parameter(Name='/bets-manager/champion/update-blocked')['Parameter']['Value'].lower() == 'true'

        result = {
            'countries':      countries,
            'insert_blocked': insert_blocked,
            'update_blocked': update_blocked,
            'champion':       None
        }

        # Get user's current champion if user_id provided
        if user_id:
            item = table.get_item(Key={'user_id': user_id}).get('Item')
            if item:
                result['champion'] = {
                    'country':    item['country'],
                    'updated_at': item.get('updated_at', '')
                }

        return {'statusCode': 200, 'headers': CORS_HEADERS, 'body': json.dumps(result)}

    except ClientError as e:
        return {'statusCode': 500, 'headers': CORS_HEADERS, 'body': json.dumps({'error': str(e)})}
