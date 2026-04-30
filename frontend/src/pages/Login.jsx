import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Login() {
  const { login, loading, error, auth } = useAuth();
  const navigate = useNavigate();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [err, setErr] = useState('');
  const [submitting, setSubmitting] = useState(false);

  // ✅ Si ya hay sesión activa, redirige sin mostrar el login
  useEffect(() => {
    if (!loading && auth) {
      auth.group === 'admin' ? navigate('/admin') : navigate('/bets');
    }
  }, [auth, loading]);

  async function handleSubmit(e) {
    e.preventDefault();
    setErr('');
    setSubmitting(true);
    try {
      const group = await login(username, password);
      if (group === 'admin') navigate('/admin');
      else if (group === 'general') navigate('/bets');
      else setErr('No tienes un grupo asignado.');
    } catch (e) {
      setErr(e.message ?? 'Error de autenticación');
    } finally {
      setSubmitting(false);
    }
  }

  if (loading) return <div className="centered">Cargando configuración...</div>;

  return (
    <div className="centered">
      <div className="card">
        <h2>🏆 Bets Manager</h2>
        {(error || err) && <p className="error">{error || err}</p>}
        <form onSubmit={handleSubmit}>
          <input
            type="text" placeholder="Usuario" required
            value={username} onChange={(e) => setUsername(e.target.value)}
          />
          <input
            type="password" placeholder="Contraseña" required
            value={password} onChange={(e) => setPassword(e.target.value)}
          />
          <button className="btn btn-blue" type="submit" disabled={submitting}>
            {submitting ? 'Ingresando...' : 'Login'}
          </button>
        </form>
      </div>
    </div>
  );
}