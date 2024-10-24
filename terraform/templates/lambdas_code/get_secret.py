import json
import boto3
import os


def lambda_handler(event, context):
    secrets_manager = boto3.client('secretsmanager')
    
    try:
        # Recupera el secreto desde Secrets Manager
        response = secrets_manager.get_secret_value(
            SecretId=os.getenv('secret_name'), VersionStage='AWSCURRENT')
        # Parsea el valor del secreto
        secret_data = json.loads(response['SecretString'])
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'UserPoolId': secret_data['UserPoolId'],
                'ClientId': secret_data['ClientId'],
                'UrlApiManageMatches': secret_data['UrlApiManageMatches'],
                'UrlApiUpdateResults': secret_data['UrlApiUpdateResults'],
                'UrlApiPutBets': secret_data['UrlApiPutBets'],
                'X-Auth-Token': secret_data['X-Auth-Token'],
                'UrlApiCreateMatchesForAPiFootballData':
                    secret_data['UrlApiCreateMatchesForAPiFootballData']
            })
        }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': str(e)})
        }
