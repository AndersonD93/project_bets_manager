import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('matches_table'))

def lambda_handler(event, context):
    try:
        # Obtener todos los partidos de la tabla
        response = table.scan()
        
        # Imprimir la respuesta de DynamoDB para depuración
        print(f"Response from DynamoDB: {response}")
        
        matches = response.get('Items', [])

        # Si no hay elementos en la respuesta
        if not matches:
            print("No se encontraron partidos en la tabla.")
        
        # Crear una lista de partidos con match_id, teams y status
        match_list = [{'match_id': match['match_id'], 'teams': match['teams'], 'status': match['status']} for match in matches] 
        
        print(f"match_list: {match_list}")

        match_list_not_finish = []

        for match in match_list:
            status = match['status'].strip()
            print(f"Estado del partido {match['match_id']}: {status}")

            if status != 'FINISHED':  # Filtra los partidos que no han terminado
                match_list_not_finish.append(match)
            else:
                print(f"Partido ya ha finalizado: {match['teams']}")

        return {
            'statusCode': 200,
            'body': json.dumps(match_list_not_finish),
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(str(e)),
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
        }
