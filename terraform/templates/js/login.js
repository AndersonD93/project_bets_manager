import { getPoolData, login } from './function.js';
import config from './config.js';

(async function () {
    try {
        const data = await getPoolData(config.apiUrlSecrets);
        if (!data) {
            throw new Error("No se obtuvieron los datos del pool");
        }

        const parsedData = typeof data === "string" ? JSON.parse(data) : data;
        const poolData = {
            UserPoolId: parsedData.UserPoolId,
            ClientId: parsedData.ClientId
        };

        if (!poolData.UserPoolId || !poolData.ClientId) {
            throw new Error("Both UserPoolId and ClientId are required.");
        }

        // Iniciar el pool aquí y pasarlo como argumento a la función login
        const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

        // Asignar el evento de login al botón, pasando `userPool` como argumento
        document.getElementById('login-button').addEventListener('click', function () {
            login(userPool); // Pasamos el `userPool` a la función de login
        });

    } catch (error) {
        console.error("Error al obtener los datos del pool:", error);
    }
})();

