import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { createMatch, getMatches, setMatchStatus } from '../api/matches';
import Navbar from '../components/Navbar';

export default function Admin() {
  const { auth, secrets } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({ match_id: '', teams: '', match_date: '' });
  const [matches, setMatches] = useState([]);
  const [msg, setMsg] = useState('');
  const [err, setErr] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingStatus, setLoadingStatus] = useState(null); // match_id being toggled

  // Load all non-finished matches (including blocked) for admin
  useEffect(() => {
    if (!secrets) return;
    getMatches(secrets.UrlApiManageMatches, auth.token, true)
      .then(setMatches)
      .catch((e) => setErr(e.message));
  }, [secrets]);

  async function handleCreateMatch(e) {
    e.preventDefault();
    setMsg(''); setErr('');
    setLoading(true);
    try {
      await createMatch(secrets.UrlApiManageMatches, auth.token, form);
      setMsg('✅ Partido creado exitosamente');
      setForm({ match_id: '', teams: '', match_date: '' });
      // Refresh list
      const updated = await getMatches(secrets.UrlApiManageMatches, auth.token, true);
      setMatches(updated);
    } catch (e) {
      setErr(`❌ ${e.message}`);
    } finally {
      setLoading(false);
    }
  }

  async function handleToggleBlock(match) {
    const newStatus = match.status?.toUpperCase() === 'BLOCKED' ? 'SCHEDULED' : 'BLOCKED';
    setLoadingStatus(match.match_id);
    setMsg(''); setErr('');
    try {
      await setMatchStatus(secrets.UrlApiManageMatchStatus, auth.token, {
        match_id: match.match_id,
        status: newStatus,
      });
      const action = newStatus === 'BLOCKED' ? 'bloqueado' : 'desbloqueado';
      setMsg(`✅ Partido "${match.teams}" ${action}`);
      const updated = await getMatches(secrets.UrlApiManageMatches, auth.token, true);
      setMatches(updated);
    } catch (e) {
      setErr(`❌ ${e.message}`);
    } finally {
      setLoadingStatus(null);
    }
  }

  function statusBadge(status) {
    const s = (status || '').toUpperCase();
    if (s === 'BLOCKED')   return <span className="badge badge-red">BLOQUEADO</span>;
    if (s === 'FINISHED')  return <span className="badge badge-gray">FINALIZADO</span>;
    return <span className="badge badge-green">ACTIVO</span>;
  }

  return (
    <>
      <Navbar />
      <div className="page-container">

        {/* Create match form */}
        <div className="card">
          <h2>Crear Partido</h2>
          {msg && <p className="success">{msg}</p>}
          {err && <p className="error">{err}</p>}
          <form onSubmit={handleCreateMatch}>
            <input placeholder="ID del Partido" required value={form.match_id}
              onChange={(e) => setForm({ ...form, match_id: e.target.value })} />
            <input placeholder="Equipos (ej. Team A vs Team B)" required value={form.teams}
              onChange={(e) => setForm({ ...form, teams: e.target.value })} />
            <label>Fecha y hora del partido</label>
            <input type="datetime-local" required value={form.match_date}
              onChange={(e) => setForm({ ...form, match_date: e.target.value })} />
            <button className="btn btn-green" type="submit" disabled={loading}>
              {loading ? 'Creando...' : 'Crear Partido'}
            </button>
          </form>
          <button className="btn btn-blue" onClick={() => navigate('/results')}>Actualizar Resultados</button>
          <button className="btn btn-blue" onClick={() => navigate('/matches')}>Cargar por Competición</button>
        </div>

        {/* Match list with block/unblock */}
        <div className="card wide">
          <h2>Gestionar Apuestas por Partido</h2>
          {matches.length === 0 ? (
            <p style={{ textAlign: 'center', color: '#888' }}>No hay partidos activos.</p>
          ) : (
            <table>
              <thead>
                <tr>
                  <th>Partido</th>
                  <th>Fecha</th>
                  <th>Estado</th>
                  <th>Apuestas</th>
                </tr>
              </thead>
              <tbody>
                {matches.map((m) => (
                  <tr key={m.match_id}>
                    <td>{m.teams}</td>
                    <td>{m.match_date ? new Date(m.match_date).toLocaleString('es-CO') : '—'}</td>
                    <td>{statusBadge(m.status)}</td>
                    <td>
                      <button
                        className={`btn btn-sm ${m.status?.toUpperCase() === 'BLOCKED' ? 'btn-green' : 'btn-red'}`}
                        disabled={loadingStatus === m.match_id}
                        onClick={() => handleToggleBlock(m)}
                      >
                        {loadingStatus === m.match_id
                          ? '...'
                          : m.status?.toUpperCase() === 'BLOCKED'
                            ? 'Desbloquear'
                            : 'Bloquear'}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

      </div>
    </>
  );
}
