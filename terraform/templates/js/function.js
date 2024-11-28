export function login(userPool) {
    console.log('Login function called');
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    const authenticationData = {
        Username: username,
        Password: password,
    };

    const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);
    const userData = {
        Username: username,
        Pool: userPool,
    };
    const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

    cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: function (result) {
            alert('Login exitoso...');
            const idToken = result.getIdToken().getJwtToken();
            const idTokenPayload = result.getIdToken().decodePayload();
            const userGroups = idTokenPayload['cognito:groups'];
            const userGroup = userGroups ? userGroups[0] : null;
            const userName = idTokenPayload['cognito:username'];

            sessionStorage.setItem('idToken', idToken);
            sessionStorage.setItem('username', userName);

            console.log("Grupo de usuario:", userGroup);

            // Ocultar formulario de login y mostrar la pantalla de opciones
            document.getElementById('login-container').classList.add('hidden');
            document.getElementById('after-login-container').classList.remove('hidden');

            // Mostrar opciones en función del grupo de usuario
            if (userGroup === 'admin') {
                document.getElementById('admin-options').classList.remove('hidden');
            } else if (userGroup === 'general') {
                document.getElementById('general-options').classList.remove('hidden');
            } else {
                alert('No tienes acceso autorizado');
            }
        },
        onFailure: function (err) {
            alert('Error de login: ' + err.message);
        },
        newPasswordRequired: function (userAttributes, requiredAttributes) {
            const newPassword = prompt('Debe establecer una nueva contraseña. Ingrese su nueva contraseña:');
            const attributesToSend = {};
            requiredAttributes.forEach(attr => {
                if (userAttributes[attr]) {
                    attributesToSend[attr] = userAttributes[attr];
                }
            });
            cognitoUser.completeNewPasswordChallenge(newPassword, attributesToSend, this);
        }
    });
}

export async function getPoolData(apiUrlSecrets) {
    try {
        // Realiza la solicitud a la API que invoca la Lambda
        const response = await fetch(apiUrlSecrets, {
            method: 'GET'
        });

        // Verifica si la solicitud fue exitosa
        if (!response.ok) {
            throw new Error("Error en la solicitud a la API: " + response.status);
        }

        // Parsear la respuesta a JSON
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error al obtener los secretos:', error);
        return null;
    }
}

export function waitForPoolData() {
    return new Promise((resolve) => {
        const interval = setInterval(() => {
            if (window.poolDataUrl) {
                clearInterval(interval);
                resolve();
            }
        }, 100);
    });
}

export function fetchScores(UrlApiUpdateResults) {
    const idToken = sessionStorage.getItem('idToken');

    // Aquí llamarías a tu API para obtener los puntajes, este es un ejemplo básico
    fetch(UrlApiUpdateResults, {
        method: 'GET',
        headers: {
            'Authorization': idToken
        }
    })
        .then(response => response.json())
        .then(data => {
            console.log('Datos recibidos de la API:', data); // Muestra la respuesta completa
            const scores = JSON.parse(data.body); // Analiza el body aquí

            if (scores && scores.length > 0) { // Verifica que hay puntajes
                displayScores(scores);
            } else {
                alert('No se encontraron puntajes.');
            }
        })
        .catch(error => {
            console.error('Error al obtener los puntajes:', error);
            alert('Hubo un problema al cargar los puntajes.');
        });
}

export function displayScores(score) {
    const tableBody = document.getElementById('scores-table').querySelector('tbody');
    tableBody.innerHTML = ''; // Limpiar la tabla

    // Asegúrate de que scores es un arreglo
    if (!Array.isArray(score)) {
        console.error('Se esperaba un arreglo de puntajes');
        return;
    }

    // Usa forEach con un parámetro de índice
    score.forEach((score, index) => {
        const row = document.createElement('tr');
        const orderCell = document.createElement('td'); // Nueva celda para el orden
        const userCell = document.createElement('td');
        const scoreCell = document.createElement('td');

        orderCell.textContent = index + 1; // Asigna el orden (índice + 1)
        userCell.textContent = score.user_id;
        scoreCell.textContent = score.total_score;

        row.appendChild(orderCell); // Agrega la celda de orden
        row.appendChild(userCell);
        row.appendChild(scoreCell);

        tableBody.appendChild(row);
    });
}

export function logout() {
    sessionStorage.removeItem('idToken');
    window.location.href = '../index.html';
}

export async function placeBet(UrlApiPutBets,match_id,bet_result,exact_score) {
    const idToken = sessionStorage.getItem('idToken');
    const username = sessionStorage.getItem('username');

    try {
        const response = await fetch(UrlApiPutBets, {
            method: 'POST',
            headers: {
                'Authorization': idToken,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                user_id: username,
                match_id: match_id,
                bet_result: bet_result,
                exact_score: exact_score
            })
        });

        if (response.ok) {
            alert('Apuesta realizada con éxito');
        } else {
            throw new Error(`Error: ${response.status} - ${response.statusText}`);
        }
    } catch (error) {
        console.error('Error al realizar la apuesta:', error);
        alert('Error al realizar la apuesta');
    }
}

export async function fetchMatches(UrlApiManageMatches) {
    const idToken = sessionStorage.getItem('idToken');
    const matchSelect = document.getElementById('match_select');
    try {
        const response = await fetch(UrlApiManageMatches, {
            method: 'GET',
            headers: {
                'Authorization': idToken,
                'Content-Type': 'application/json'
            },
        });

        if (!response.ok) {
            throw new Error(`Error: ${response.status} - ${response.statusText}`);
        }

        const responseData = await response.json();
        console.log("API response:", responseData);

        // Parsear el cuerpo si viene como string
        const matches = JSON.parse(responseData.body);

        // Verificar si matches es un array
        if (Array.isArray(matches)) {
            matches.forEach(match => {
                const option = document.createElement('option');
                option.value = match.match_id;
                option.textContent = `${match.teams} (ID: ${match.match_id})`;
                matchSelect.appendChild(option);
            });
        } else {
            console.error("El cuerpo de la respuesta no es un array. Estructura:", matches);
            alert('Error: el cuerpo de la respuesta no es un array');
        }

    } catch (error) {
        console.error('Error al cargar los partidos:', error);
        alert('Error al cargar los partidos');
    }
}

export async function updateResult(UrlApi,match_id, real_result, exact_score) {
    const idToken = sessionStorage.getItem('idToken');

    if (!match_id) {
        alert('Por favor seleccione un partido');
        return;
    }

    const response = await fetch(UrlApi, {
        method: 'POST',
        headers: {
            'Authorization': idToken,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            match_id,
            real_result,
            exact_score
        })
    });

    const result = await response.json();
    if (response.ok) {
        alert('Resultado actualizado exitosamente');
    } else {
        alert('Error: ' + result.body);
    }
}

export async function createMatch(UrlApiManageMatches) {
    const idToken = sessionStorage.getItem('idToken');
    const match_id = document.getElementById('match_id').value;
    const teams = document.getElementById('teams').value;
    const match_date = document.getElementById('match_date').value;

    const response = await fetch(UrlApiManageMatches, {
        method: 'POST',
        headers: {
            'Authorization': idToken,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            match_id,
            teams,
            match_date
        })
    });

    const result = await response.json();
    if (response.ok) {
        alert('Partido creado exitosamente');
    } else {
        alert('Error: ' + result.body);
    }
}

export async function fetchCreateMatches(createMatchesUrl,competitionId,matchday) {
    const idToken = sessionStorage.getItem('idToken');
    try {
        const apiResponse = await fetch(createMatchesUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': idToken
            },
            body: JSON.stringify({
                competition_id: competitionId,
                matchday: matchday
            })
        });

        const responseData = await apiResponse.json();

        if (apiResponse.ok) {
            alert('Partido creado exitosamente '+ responseData.message);
        } else {
            alert('Error: ' + responseData.message);
        }

    } catch (error) {
        console.error('Error:', error);
        document.getElementById('response').innerText = `Error: ${error.message}`;
    }
}