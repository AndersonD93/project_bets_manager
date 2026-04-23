import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';

export default function Navbar() {
  const { auth, logout } = useAuth();
  const navigate = useNavigate();

  function handleLogout() {
    logout();
    navigate('/');
  }

  if (!auth) return null;

  return (
    <nav className="navbar">
      <span className="navbar-user">👤 {auth.username} <span className="badge">{auth.group}</span></span>
      <button className="btn btn-red" onClick={handleLogout}>Logout</button>
    </nav>
  );
}
