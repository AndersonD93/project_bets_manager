import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { getMatches } from '../api/matches';
import { placeBet } from '../api/bets';
import Navbar from '../components/Navbar';

export default function Bets() {
  const { auth, secrets } = useAuth();
  const navigate = useNavigate();
  const [matches, setMatches] = useState([]);
  const [form, setForm] = useState({ match_id: '', bet_result: '', local_goals: '', away_goals: '' });
  const [msg, setMsg] = useState('');
  const [err, setErr] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!secrets) return;
    getMatches(secrets.UrlApiManageMatches, auth.token)
      .then(setMatches)
      .catch((e) => setErr(e.message));
  }, [secrets]);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!form.match_id || !form.bet_result || form.local_goals === '' || form.away_goals === '')
      return setErr('Completa todos los campos');
    setMsg(''); setErr('');
    setLoading(true);
    try {
      const exact_score = `${form.local_goals}-${form.away_goals}`;
      await placeBet(secrets.UrlApiPutBets, auth.token, {
        user_id: auth.username,
        match_id: form.match_id,
        bet_result: form.bet_result,
        exact_score,
      });
      setMsg('✅ Apuesta registrada exitosamente');
      setForm({ match_id: '', bet_result: '', local_goals: '', away_goals: '' });
    } catch (e) {
      setErr(`❌ ${e.message}`);
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      <Navbar />
      <div className="centered">
        <div className="card">
          <h2>Realizar Apuesta</h2>
          {msg && <p className="success">{msg}</p>}
          {err && <p className="error">{err}</p>}
          <form onSubmit={handleSubmit}>
            <select value={form.match_id} onChange={(e) => setForm({ ...form, match_id: e.target.value })} required>
              <option value="">Seleccione un partido</option>
              {matches.map((m) => (
                <option key={m.match_id} value={m.match_id}>{m.teams}</option>
              ))}
            </select>
            <select value={form.bet_result} onChange={(e) => setForm({ ...form, bet_result: e.target.value })} required>
              <option value="">Seleccione el resultado</option>
              <option value="home_win">Gana equipo local</option>
              <option value="away_win">Gana equipo visitante</option>
              <option value="draw">Empate</option>
            </select>
            <div className="goals-row">
              <div>
                <label>Goles Local</label>
                <input type="number" min="0" required value={form.local_goals}
                  onChange={(e) => setForm({ ...form, local_goals: e.target.value })} />
              </div>
              <div>
                <label>Goles Visitante</label>
                <input type="number" min="0" required value={form.away_goals}
                  onChange={(e) => setForm({ ...form, away_goals: e.target.value })} />
              </div>
            </div>
            <button className="btn btn-blue" type="submit" disabled={loading}>
              {loading ? 'Apostando...' : 'Realizar Apuesta'}
            </button>
          </form>
          <button className="btn btn-green" onClick={() => navigate('/scores')}>Ver Puntajes</button>
          <button className="btn btn-blue" onClick={() => navigate('/champion')}>🏆 Mi Campeón</button>
        </div>
      </div>
    </>
  );
}
