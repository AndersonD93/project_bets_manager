import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { getScores } from '../api/results';
import Navbar from '../components/Navbar';

export default function Scores() {
  const { auth, secrets } = useAuth();
  const navigate = useNavigate();
  const [scores, setScores] = useState([]);
  const [err, setErr] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!secrets) return;
    getScores(secrets.UrlApiUpdateResults, auth.token)
      .then((data) => {
        const list = Array.isArray(data) ? data : [];
        setScores([...list].sort((a, b) => b.total_score - a.total_score));
      })
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  }, [secrets]);

  return (
    <>
      <Navbar />
      <div className="centered">
        <div className="card wide">
          <h2>🏅 Ranking de Puntajes</h2>
          {err && <p className="error">{err}</p>}
          {loading ? (
            <p>Cargando puntajes...</p>
          ) : scores.length === 0 ? (
            <p>No hay puntajes registrados aún.</p>
          ) : (
            <table>
              <thead>
                <tr><th>#</th><th>Usuario</th><th>Puntaje</th></tr>
              </thead>
              <tbody>
                {scores.map((s, i) => (
                  <tr key={s.user_id}>
                    <td>{i + 1}</td>
                    <td>{s.user_id}</td>
                    <td>{s.total_score}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
          <button className="btn btn-blue" onClick={() => navigate('/bets')}>Realizar Apuesta</button>
        </div>
      </div>
    </>
  );
}
