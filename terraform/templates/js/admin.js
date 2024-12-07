import { getPoolData, waitForPoolData, fetchMatches, logout, createMatch } from './function.js';
import config from './config.js';

window.poolDataUrl = null;
(async function () {
    try {
        const data = await getPoolData(config.apiUrlSecrets);
        if (!data) {
            throw new Error("No se obtuvieron los datos del pool");
        }
        const parsedBody = typeof data === "string" ? JSON.parse(data) : data;

        if (parsedBody.UrlApiManageMatches && parsedBody.UrlApiPutBets) {
            window.poolDataUrl = {
                UrlApiManageMatches: parsedBody.UrlApiManageMatches
            };
        } else {
            console.error("No se obtuvieron UrlApiManageMatches.");
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
        console.log('Autenticación Correcta');
    }
});

document.getElementById('logout-button').addEventListener('click', function () {
    logout();
});

document.getElementById('creat-match-button').addEventListener('click', function () {
    createMatch(window.poolDataUrl.UrlApiManageMatches);
});