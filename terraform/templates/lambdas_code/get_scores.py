import json
import boto3
from decimal import Decimal
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('score_user_table'))


# Función para convertir objetos Decimal a tipos serializables
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
        # Escanea la tabla para obtener los puntajes
        response = table.scan()

        # Obtiene los elementos de la respuesta
        items = response.get('Items', [])

        # Verifica si hay puntajes en la tabla
        if not items:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'No se encontraron puntajes.'}),
                'headers': {
                    "Access-Control-Allow-Origin": "*",
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type, Authorization"
                },
            }

        # Convertir Decimals a tipos nativos de Python
        items = decimal_to_native(items)

        # Ordena los puntajes de mayor a menor
        sorted_items = sorted(items, key=lambda x: x['total_score'], reverse=True)

        # Retorna los datos ordenados
        return {
            'statusCode': 200,
            'body': json.dumps(sorted_items),
            'headers': {
                    "Access-Control-Allow-Origin": "*",
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type, Authorization"
                },
        }

    except Exception as e:
        # Maneja cualquier error y registra en CloudWatch
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f"Error interno al obtener los puntajes: {str(e)}"}),
            'headers': {
                    "Access-Control-Allow-Origin": "*",
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type, Authorization"
                },
        }
