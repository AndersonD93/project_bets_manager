import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('matches_table'))


def lambda_handler(event, context):
    try:
        # Obtener todos los partidos de la tabla
        response = table.scan()
        matches = response.get('Items', [])

        # Crear una lista de partidos con match_id y teams
        match_list = [{'match_id': match['match_id'], 'teams': match['teams'], 'status':match['status']} for match in matches]
        
        print(f"match_list {match_list}")
        
        match_list_not_finish = []
        
        for match in match_list:
            if match['status'] != 'FINISHED':
                match_list_not_finish.append(match)
            else:
                print(f"Partido ya ha finalizado {match['teams']}")
                
        return {
            'statusCode': 200,
            'body': json.dumps(match_list_not_finish),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # Permitir el acceso desde el frontend
            }
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(str(e)),
            'headers': {
                'Content-Type': 'application/json'
            }
        }
