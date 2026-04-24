import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { getChampionData, putChampion } from '../api/champion';
import Navbar from '../components/Navbar';

// Flag emoji from country name using Unicode regional indicators
function flagEmoji(country) {
  const map = {
    'Uruguay': '🇺🇾', 'Germany': '🇩🇪', 'Spain': '🇪🇸', 'Paraguay': '🇵🇾',
    'Argentina': '🇦🇷', 'Ghana': '🇬🇭', 'Brazil': '🇧🇷', 'Portugal': '🇵🇹',
    'Japan': '🇯🇵', 'Mexico': '🇲🇽', 'England': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'USA': '🇺🇸',
    'Korea Republic': '🇰🇷', 'France': '🇫🇷', 'South Africa': '🇿🇦',
    'Algeria': '🇩🇿', 'Australia': '🇦🇺', 'New Zealand': '🇳🇿',
    'Switzerland': '🇨🇭', 'Ecuador': '🇪🇨', 'Sweden': '🇸🇪', 'Czechia': '🇨🇿',
    'Croatia': '🇭🇷', 'Saudi Arabia': '🇸🇦', 'Tunisia': '🇹🇳', 'Turkey': '🇹🇷',
    'Senegal': '🇸🇳', 'Belgium': '🇧🇪', 'Morocco': '🇲🇦', 'Austria': '🇦🇹',
    'Colombia': '🇨🇴', 'Egypt': '🇪🇬', 'Canada': '🇨🇦', 'Haiti': '🇭🇹',
    'Iran': '🇮🇷', 'Bosnia-H.': '🇧🇦', 'Panama': '🇵🇦', 'Cape Verde': '🇨🇻',
    'Congo DR': '🇨🇩', 'Ivory Coast': '🇨🇮', 'Qatar': '🇶🇦', 'Jordan': '🇯🇴',
    'Iraq': '🇮🇶', 'Uzbekistan': '🇺🇿', 'Netherlands': '🇳🇱', 'Norway': '🇳🇴',
    'Scotland': '🏴󠁧󠁢󠁳󠁣󠁴󠁿', 'Curaçao': '🇨🇼',
  };
  return map[country] || '🏳️';
}

export default function Champion() {
  const { auth, secrets } = useAuth();
  const navigate = useNavigate();

  const [countries, setCountries]         = useState([]);
  const [selected, setSelected]           = useState('');
  const [current, setCurrent]             = useState(null);   // existing champion
  const [insertBlocked, setInsertBlocked] = useState(false);
  const [updateBlocked, setUpdateBlocked] = useState(false);
  const [msg, setMsg]   = useState('');
  const [err, setErr]   = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving]   = useState(false);

  useEffect(() => {
    if (!secrets) return;
    getChampionData(secrets.UrlApiChampion, auth.token, auth.username)
      .then((data) => {
        setCountries(data.countries || []);
        setInsertBlocked(data.insert_blocked || false);
        setUpdateBlocked(data.update_blocked || false);
        if (data.champion) {
          setCurrent(data.champion);
          setSelected(data.champion.country);
        }
      })
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  }, [secrets]);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!selected) return setErr('Selecciona un país');
    setMsg(''); setErr(''); setSaving(true);
    try {
      const res = await putChampion(secrets.UrlApiChampion, auth.token, {
        user_id: auth.username,
        country: selected,
      });
      setMsg(`✅ ${res}`);
      setCurrent({ country: selected, updated_at: new Date().toISOString() });
    } catch (e) {
      setErr(`❌ ${e.message}`);
    } finally {
      setSaving(false);
    }
  }

  const isUpdate   = current !== null;
  const isDisabled = isUpdate ? updateBlocked : insertBlocked;

  return (
    <>
      <Navbar />
      <div className="centered">
        <div className="card">
          <h2>🏆 Mi Campeón del Mundial 2026</h2>

          {loading ? <p>Cargando...</p> : (
            <>
              {current && (
                <div style={{ textAlign: 'center', padding: '16px 0', fontSize: '1.1rem' }}>
                  <div style={{ fontSize: '3rem' }}>{flagEmoji(current.country)}</div>
                  <p style={{ fontWeight: 700, marginTop: 8 }}>{current.country}</p>
                  <p style={{ fontSize: 12, color: '#888' }}>
                    Registrado: {new Date(current.updated_at).toLocaleString('es-CO')}
                  </p>
                </div>
              )}

              {isDisabled ? (
                <p className="error" style={{ textAlign: 'center' }}>
                  {isUpdate
                    ? '🔒 La modificación de campeón está bloqueada por el administrador.'
                    : '🔒 El registro de campeón está bloqueado por el administrador.'}
                </p>
              ) : (
                <form onSubmit={handleSubmit}>
                  {msg && <p className="success">{msg}</p>}
                  {err && <p className="error">{err}</p>}
                  <label>{isUpdate ? 'Cambiar campeón' : 'Selecciona tu campeón'}</label>
                  <select value={selected} onChange={(e) => setSelected(e.target.value)} required>
                    <option value="">— Selecciona un país —</option>
                    {countries.map((c) => (
                      <option key={c} value={c}>{flagEmoji(c)} {c}</option>
                    ))}
                  </select>
                  {selected && (
                    <div style={{ textAlign: 'center', fontSize: '3rem', margin: '8px 0' }}>
                      {flagEmoji(selected)}
                    </div>
                  )}
                  <button className="btn btn-green" type="submit" disabled={saving}>
                    {saving ? 'Guardando...' : isUpdate ? '🔄 Actualizar Campeón' : '✅ Registrar Campeón'}
                  </button>
                </form>
              )}

              <button className="btn btn-blue" onClick={() => navigate('/bets')}>Realizar Apuesta</button>
              <button className="btn btn-blue" onClick={() => navigate('/scores')}>Ver Puntajes</button>
            </>
          )}
        </div>
      </div>
    </>
  );
}
