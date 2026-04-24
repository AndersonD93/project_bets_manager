import json
import boto3
import os

CORS_HEADERS = {
    'Access-Control-Allow-Origin': 'https://d3iqu3owmhprm.cloudfront.net',
    'Content-Type': 'application/json'
}


def lambda_handler(event, context):
    secrets_manager = boto3.client('secretsmanager')

    try:
        response = secrets_manager.get_secret_value(
            SecretId=os.getenv('secret_name'), VersionStage='AWSCURRENT')
        secret_data = json.loads(response['SecretString'])

        # Return all keys except sensitive ones
        safe_keys = {k: v for k, v in secret_data.items() if k != 'X-Auth-Token'}

        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps(safe_keys)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': CORS_HEADERS,
            'body': json.dumps({'error': str(e)})
        }
