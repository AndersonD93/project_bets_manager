import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';
import Admin from './pages/Admin';
import Matches from './pages/Matches';
import Results from './pages/Results';
import Bets from './pages/Bets';
import Scores from './pages/Scores';

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Login />} />

          {/* Admin routes */}
          <Route path="/admin" element={
            <ProtectedRoute allowedGroup="admin"><Admin /></ProtectedRoute>
          } />
          <Route path="/matches" element={
            <ProtectedRoute allowedGroup="admin"><Matches /></ProtectedRoute>
          } />
          <Route path="/results" element={
            <ProtectedRoute allowedGroup="admin"><Results /></ProtectedRoute>
          } />

          {/* General routes */}
          <Route path="/bets" element={
            <ProtectedRoute allowedGroup="general"><Bets /></ProtectedRoute>
          } />
          <Route path="/scores" element={
            <ProtectedRoute allowedGroup="general"><Scores /></ProtectedRoute>
          } />

          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
