import { useEffect } from 'react';
import { useAuth } from '../context/AuthContext';

export default function Scores() {
  const { auth, secrets } = useAuth();

  useEffect(() => {
    if (!auth || !secrets) return;

    const base = secrets.UrlApiUpdateResults.replace('/update_results', '');
    sessionStorage.setItem('apiBase',          base);
    sessionStorage.setItem('apiUpdateResults', secrets.UrlApiUpdateResults);
    sessionStorage.setItem('apiGetResults',    secrets.UrlApiGetResults    || `${base}/get_results`);
    sessionStorage.setItem('apiGetBets',       secrets.UrlApiGetBets       || `${base}/get_bets`);
    sessionStorage.setItem('idToken',          auth.token);
    sessionStorage.setItem('username',         auth.username);

    window.location.href = '/html/dashboard.html';
  }, [auth, secrets]);

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
      <p style={{ color: '#888' }}>Redirigiendo al dashboard...</p>
    </div>
  );
}
