import json
import boto3
import os

ssm = boto3.client('ssm')

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://d3iqu3owmhprm.cloudfront.net",
    "Content-Type": "application/json",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}


def lambda_handler(event, context):
    try:
        countries_raw = ssm.get_parameter(Name='/bets-manager/world-cup-2026/countries')['Parameter']['Value']
        countries = sorted([c.strip() for c in countries_raw.split(',')])

        winner = ssm.get_parameter(Name='/bets-manager/champion/tournament-winner')['Parameter']['Value']

        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps({
                'countries':       countries,
                'current_winner':  winner  # empty string = not set
            })
        }
    except Exception as e:
        return {'statusCode': 500, 'headers': CORS_HEADERS,
                'body': json.dumps({'error': str(e)})}
