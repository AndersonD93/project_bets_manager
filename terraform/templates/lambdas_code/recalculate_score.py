import json
import boto3
from botocore.exceptions import ClientError
import os

dynamodb                     = boto3.resource('dynamodb')
bets_table                   = dynamodb.Table(os.getenv('bets_table'))
results_table                = dynamodb.Table(os.getenv('results_table'))
score_table                  = dynamodb.Table(os.getenv('score_table'))
bets_users_global_index_name = os.getenv('bets_users_global_index_name')


def lambda_handler(event, context):
    try:
        # Procesar todos los registros que llegan en el evento
        for record in event['Records']:
            # Revisar si el evento es una modificación o inserción
            if record['eventName'] in ['MODIFY', 'INSERT']:
                # Extraer el match_id de NewImage
                match_id = record['dynamodb']['NewImage']['match_id']['S']
                
                # Obtener los resultados reales desde el evento
                real_result = record['dynamodb']['NewImage']['real_result']['S']
                exact_score = record['dynamodb']['NewImage']['exact_score']['S']

                # Obtener todas las apuestas de los usuarios para este partido
                bets = bets_table.query(
                    IndexName=bets_users_global_index_name,
                    KeyConditionExpression="match_id = :match_id",
                    ExpressionAttributeValues={":match_id": match_id}
                )['Items']

                for bet in bets:
                    user_id = bet['user_id']
                    bet_result = bet['bet_result']
                    bet_exact_score = bet['exact_score']

                    # Obtener el puntaje previo del usuario en este partido (si lo había)
                    previous_score = 0
                    if 'score' in bet:
                        previous_score = int(bet['score'])  # Suponiendo que has almacenado el puntaje del usuario por partido

                    # Calcular nuevo puntaje
                    new_score = 0
                    if bet_result == real_result:
                        new_score += 3
                    if bet_exact_score == exact_score:
                        new_score += 3

                    # Si el puntaje ha cambiado, actualizamos el total_score del usuario
                    if previous_score != new_score:
                        # Primero restamos el puntaje previo
                        score_table.update_item(
                            Key={'user_id': user_id},
                            UpdateExpression="ADD total_score :score",
                            ExpressionAttributeValues={':score': -previous_score}
                        )
                        
                        # Luego agregamos el nuevo puntaje
                        score_table.update_item(
                            Key={'user_id': user_id},
                            UpdateExpression="ADD total_score :score",
                            ExpressionAttributeValues={':score': new_score}
                        )

                    # Actualizamos el puntaje por partido para futuras actualizaciones
                    bets_table.update_item(
                        Key={'user_id': user_id, 'match_id': match_id},
                        UpdateExpression="SET score = :score",
                        ExpressionAttributeValues={':score': new_score}
                    )

        return {
            'statusCode': 200,
            'body': json.dumps('Puntajes recalculados exitosamente.')
        }

    except ClientError as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error: {str(e)}")
        }
    except KeyError as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error: Key {str(e)} not found in event.")
        }
