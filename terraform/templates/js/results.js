import { getPoolData, waitForPoolData, fetchMatches, logout, updateResult } from './function.js';
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

document.getElementById('logout-button').addEventListener('click', function () {
    logout();
});

document.getElementById('update-result-button').addEventListener('click', async function () {
    const selectedMatch = document.getElementById('match_select').value;
    const realResult = document.getElementById('real_result').value;
    const localGoals = document.getElementById('local_goals').value;
    const awayGoals = document.getElementById('away_goals').value;

    if (selectedMatch && realResult && localGoals !== "" && awayGoals !== "") {
        const exactScore = `${localGoals}-${awayGoals}`; // Concatenar los goles locales y visitantes

        try {
            const response = await updateResult(window.poolDataUrl.UrlApiUpdateResults, selectedMatch, realResult, exactScore);

            if (response !== null) { // Comparación corregida
                alert("Resultado actualizado exitosamente.");
                window.location.href = "results.html";
            } else {
                const errorData = await response.json();
                alert(`Error al actualizar: ${errorData.message || "Error desconocido."}`);
            }
        } catch (error) {
            alert(`Error de red: ${error.message}`);
        }
    } else {
        alert("Por favor, complete todos los campos.");
    }
});