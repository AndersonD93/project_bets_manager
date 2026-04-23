import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { createMatch } from '../api/matches';
import Navbar from '../components/Navbar';

export default function Admin() {
  const { auth, secrets } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ match_id: '', teams: '', match_date: '' });
  const [msg, setMsg] = useState('');
  const [err, setErr] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setMsg(''); setErr('');
    setLoading(true);
    try {
      await createMatch(secrets.UrlApiManageMatches, auth.token, form);
      setMsg('✅ Partido creado exitosamente');
      setForm({ match_id: '', teams: '', match_date: '' });
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
          <h2>Crear Partido</h2>
          {msg && <p className="success">{msg}</p>}
          {err && <p className="error">{err}</p>}
          <form onSubmit={handleSubmit}>
            <input placeholder="ID del Partido" required value={form.match_id}
              onChange={(e) => setForm({ ...form, match_id: e.target.value })} />
            <input placeholder="Equipos (ej. Team A vs Team B)" required value={form.teams}
              onChange={(e) => setForm({ ...form, teams: e.target.value })} />
            <input type="datetime-local" required value={form.match_date}
              onChange={(e) => setForm({ ...form, match_date: e.target.value })} />
            <button className="btn btn-green" type="submit" disabled={loading}>
              {loading ? 'Creando...' : 'Crear Partido'}
            </button>
          </form>
          <button className="btn btn-blue" onClick={() => navigate('/results')}>Actualizar Resultados</button>
          <button className="btn btn-blue" onClick={() => navigate('/matches')}>Cargar por Competición</button>
        </div>
      </div>
    </>
  );
}
