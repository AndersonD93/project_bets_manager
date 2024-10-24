import { getPoolData, login } from './function.js';
        const apiUrlSecrets = 'https://vj8nf8d3sl.execute-api.us-east-1.amazonaws.com/v1/get_secret';
    
        (async function() {
            try {
                const data = await getPoolData(apiUrlSecrets);
                if (!data.body) {
                    throw new Error("No se obtuvieron los datos del pool");
                }
                
                const parsedBody = JSON.parse(data.body);
                const poolData = {
                    UserPoolId: parsedBody.UserPoolId,
                    ClientId: parsedBody.ClientId
                };

                if (!poolData.UserPoolId || !poolData.ClientId) {
                    throw new Error("Both UserPoolId and ClientId are required.");
                }
    
                // Iniciar el pool aquí y pasarlo como argumento a la función login
                const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
    
                // Asignar el evento de login al botón, pasando `userPool` como argumento
                document.getElementById('login-button').addEventListener('click', function() {
                    login(userPool); // Pasamos el `userPool` a la función de login
                });
    
            } catch (error) {
                console.error("Error al obtener los datos del pool:", error);
            }
        })();

        