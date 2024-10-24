import { getPoolData, waitForPoolData,fetchScores,displayScores,logout } from './function.js';
import config  from './config.js';

window.poolDataUrl = null;
(async function() {
    try {
        const data = await getPoolData(config.apiUrlSecrets);
        const parsedBody = JSON.parse(data.body);

        if (parsedBody.UrlApiUpdateResults && parsedBody.UrlApiPutBets) {
            window.poolDataUrl = {
                UrlApiUpdateResults: parsedBody.UrlApiUpdateResults,
                UrlApiPutBets: parsedBody.UrlApiPutBets
            };
        } else {
            console.error("No se obtuvieron UrlApiUpdateResults o UrlApiPutBets.");
        }
    } catch (error) {
        console.error("Error al obtener los datos del poolDataUrl:", error);
    }
})();

document.addEventListener('DOMContentLoaded', async function () {
    console.log("DOMContentLoaded ejecutado");
    await waitForPoolData();

    const idToken = sessionStorage.getItem('idToken');
    if (!idToken) {
        alert("No estás autenticado. Serás redirigido al login.");
        window.location.href = 'index.html';
    } else {
        fetchScores(window.poolDataUrl.UrlApiUpdateResults);
    }
});

document.getElementById('logout-button').addEventListener('click', function() {
    logout();
});