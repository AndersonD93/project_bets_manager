import { getPoolData, waitForPoolData,fetchMatches,logout,updateResult } from './function.js';

const apiUrlSecrets = 'https://vj8nf8d3sl.execute-api.us-east-1.amazonaws.com/v1/get_secret';

window.poolDataUrl = null;
(async function() {
    try {
        const data = await getPoolData(apiUrlSecrets);
        const parsedBody = JSON.parse(data.body);

        if (parsedBody.UrlApiManageMatches && parsedBody.UrlApiPutBets) {
            window.poolDataUrl = {
                UrlApiManageMatches: parsedBody.UrlApiManageMatches,
                UrlApiUpdateResults: parsedBody.UrlApiUpdateResults
            };
        } else {
            console.error("No se obtuvieron UrlApiManageMatches o UrlApiUpdateResults.");
        }
    } catch (error) {
        console.error("Error al obtener los datos del poolDataUrl:", error);
    }
})();

document.addEventListener('DOMContentLoaded', async function () {
    console.log("DOMContentLoaded ejecutado");
    

    const matchSelect = document.getElementById('match_select');
    const idToken = sessionStorage.getItem('idToken');
    
    await waitForPoolData();

    if (!idToken) {
        alert("No estás autenticado. Serás redirigido al login.");
        window.location.href = 'index.html';
    } else {
        fetchMatches(window.poolDataUrl.UrlApiManageMatches);
    }
});

document.getElementById('logout-button').addEventListener('click', function() {
    logout();
});

document.getElementById('update-result-button').addEventListener('click', function() {
    const selectedMatch = document.getElementById('match_select').value;
    const realResult = document.getElementById('real_result').value;
    const localGoals = document.getElementById('local_goals').value;
    const awayGoals = document.getElementById('away_goals').value;

    if (selectedMatch && realResult && localGoals !== "" && awayGoals !== "") {
        const exactScore = `${localGoals}-${awayGoals}`; // Concatenar los goles locales y visitantes
        updateResult(window.poolDataUrl.UrlApiUpdateResults, selectedMatch, realResult, exactScore);
    } else {
        alert("Por favor, complete todos los campos.");
    }
});