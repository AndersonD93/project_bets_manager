import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { getMatches } from '../api/matches';
import { updateResult } from '../api/results';
import Navbar from '../components/Navbar';

export default function Results() {
  const { auth, secrets } = useAuth();
  const navigate = useNavigate();
  const [matches, setMatches] = useState([]);
  const [form, setForm] = useState({ match_id: '', real_result: '', local_goals: '', away_goals: '' });
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
    if (!form.match_id) return setErr('Selecciona un partido');
    setMsg(''); setErr('');
    setLoading(true);
    try {
      const exact_score = `${form.local_goals}-${form.away_goals}`;
      await updateResult(secrets.UrlApiUpdateResults, auth.token, {
        match_id: form.match_id,
        real_result: form.real_result,
        exact_score,
      });
      setMsg('✅ Resultado actualizado exitosamente');
      setForm({ match_id: '', real_result: '', local_goals: '', away_goals: '' });
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
          <h2>Actualizar Resultados</h2>
          {msg && <p className="success">{msg}</p>}
          {err && <p className="error">{err}</p>}
          <form onSubmit={handleSubmit}>
            <select value={form.match_id} onChange={(e) => setForm({ ...form, match_id: e.target.value })} required>
              <option value="">Seleccione un partido</option>
              {matches.map((m) => (
                <option key={m.match_id} value={m.match_id}>{m.teams}</option>
              ))}
            </select>
            <select value={form.real_result} onChange={(e) => setForm({ ...form, real_result: e.target.value })} required>
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
            <button className="btn btn-green" type="submit" disabled={loading}>
              {loading ? 'Actualizando...' : 'Actualizar Resultado'}
            </button>
          </form>
          <button className="btn btn-blue" onClick={() => navigate('/admin')}>Crear Partido</button>
          <button className="btn btn-blue" onClick={() => navigate('/matches')}>Cargar por Competición</button>
        </div>
      </div>
    </>
  );
}
