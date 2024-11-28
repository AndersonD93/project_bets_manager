import { getPoolData, waitForPoolData,fetchCreateMatches,logout} from './function.js';
import config  from './config.js';


window.poolDataUrl = null;
(async function() {
    try {
        const data = await getPoolData(config.apiUrlSecrets);
                if (!data) {
                    throw new Error("No se obtuvieron los datos del pool");
                }
        const parsedData = typeof data === "string" ? JSON.parse(data) : data;

        if (parsedData.UrlApiCreateMatchesForAPiFootballData) {
            window.poolDataUrl = {
                UrlApiCreateMatchesForAPiFootballData: parsedData.UrlApiCreateMatchesForAPiFootballData
            };
        } else {
            console.error("No se obtuvieron UrlApiCreateMatchesForAPiFootballData.");
        }
    } catch (error) {
        console.error("Error al obtener los datos del poolDataUrl:", error);
    }
})();

document.getElementById('matchesForm').addEventListener('submit', async function (event) {
    event.preventDefault(); // Evita el envío por defecto del formulario
    console.log("DOMContentLoaded ejecutado");

    const competitionId = document.getElementById('competition_id').value;
    const matchday = document.getElementById('matchday').value;
    const idToken = sessionStorage.getItem('idToken');

    await waitForPoolData();

    if (!idToken) {
        alert("No estás autenticado. Serás redirigido al login.");
        window.location.href = 'index.html';
    } else {
        console.log('Autenticación Correcta');
        fetchCreateMatches(window.poolDataUrl.UrlApiCreateMatchesForAPiFootballData,competitionId,matchday);
    }
});
