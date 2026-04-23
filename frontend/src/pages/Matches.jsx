import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { loadMatchesFromApi } from '../api/matches';
import Navbar from '../components/Navbar';

const COMPETITIONS = [
  { value: 'WC', label: 'FIFA World Cup' },
  { value: 'CL', label: 'UEFA Champions League' },
  { value: 'BL1', label: 'Bundesliga' },
  { value: 'DED', label: 'Eredivisie' },
  { value: 'BSA', label: 'Campeonato Brasileiro Série A' },
  { value: 'PD', label: 'Primera Division' },
  { value: 'FL1', label: 'Ligue 1' },
  { value: 'ELC', label: 'Championship' },
  { value: 'PPL', label: 'Primeira Liga' },
  { value: 'EC', label: 'European Championship' },
  { value: 'SA', label: 'Serie A' },
  { value: 'PL', label: 'Premier League' },
  { value: 'CLI', label: 'Copa Libertadores' },
];

export default function Matches() {
  const { auth, secrets } = useAuth();
  const navigate = useNavigate();
  const [competition_id, setCompetitionId] = useState('PL');
  const [matchday, setMatchday] = useState('');
  const [msg, setMsg] = useState('');
  const [err, setErr] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setMsg(''); setErr('');
    setLoading(true);
    try {
      const res = await loadMatchesFromApi(
        secrets.UrlApiCreateMatchesForAPiFootballData,
        auth.token,
        { competition_id, matchday: Number(matchday) }
      );
      setMsg(`✅ ${res.message ?? 'Partidos cargados exitosamente'}`);
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
          <h2>Cargar Partidos por Competición</h2>
          {msg && <p className="success">{msg}</p>}
          {err && <p className="error">{err}</p>}
          <form onSubmit={handleSubmit}>
            <label>Competencia</label>
            <select value={competition_id} onChange={(e) => setCompetitionId(e.target.value)}>
              {COMPETITIONS.map((c) => (
                <option key={c.value} value={c.value}>{c.label}</option>
              ))}
            </select>
            <label>Fecha No. (Matchday)</label>
            <input type="number" required min="1" value={matchday}
              onChange={(e) => setMatchday(e.target.value)} placeholder="Ej: 5" />
            <button className="btn btn-green" type="submit" disabled={loading}>
              {loading ? 'Cargando...' : 'Cargar Partidos'}
            </button>
          </form>
          <button className="btn btn-blue" onClick={() => navigate('/admin')}>Crear Partido Manual</button>
          <button className="btn btn-blue" onClick={() => navigate('/results')}>Actualizar Resultados</button>
        </div>
      </div>
    </>
  );
}
