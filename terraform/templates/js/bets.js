import { getPoolData, waitForPoolData,fetchMatches,logout,placeBet } from './function.js';
import config  from './config.js';

window.poolDataUrl = null;
(async function() {
    try {
        const data = await getPoolData(config.apiUrlSecrets);
        const parsedBody = JSON.parse(data.body);

        if (parsedBody.UrlApiManageMatches && parsedBody.UrlApiPutBets) {
            window.poolDataUrl = {
                UrlApiManageMatches: parsedBody.UrlApiManageMatches,
                UrlApiPutBets: parsedBody.UrlApiPutBets
            };
        } else {
            console.error("No se obtuvieron UrlApiManageMatches o UrlApiPutBets.");
        }
    } catch (error) {
        console.error("Error al obtener los datos del poolDataUrl:", error);
    }
})();

document.addEventListener('DOMContentLoaded', async function () {
    console.log("DOMContentLoaded ejecutado");
    

    const matchSelect = document.getElementById('match_select');
    const idToken = sessionStorage.getItem('idToken');
    const username = sessionStorage.getItem('username');
    
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

document.getElementById('place-bet-button').addEventListener('click', function() {
    const selectedMatch = document.getElementById('match_select').value;
    const realResult = document.getElementById('bet_result').value;
    const localGoals = document.getElementById('local_goals').value;
    const awayGoals = document.getElementById('away_goals').value;

    if (selectedMatch && realResult && localGoals !== "" && awayGoals !== "") {
        const exactScore = `${localGoals}-${awayGoals}`; // Concatenar los goles locales y visitantes
        placeBet(window.poolDataUrl.UrlApiPutBets, selectedMatch, realResult, exactScore);
    } else {
        alert("Por favor, complete todos los campos.");
    }
});