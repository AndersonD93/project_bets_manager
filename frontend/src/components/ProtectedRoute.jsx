import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function ProtectedRoute({ children, allowedGroup }) {
  const { auth, loading } = useAuth();

  if (loading) return <div className="centered">Cargando...</div>;
  if (!auth) return <Navigate to="/" replace />;
  if (allowedGroup && auth.group !== allowedGroup) return <Navigate to="/" replace />;

  return children;
}
