import React, { useEffect, useState } from 'react';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import { jwtDecode } from 'jwt-decode';
import { NotificationProvider } from './contexts/NotificationContext';

export default function App() {
  const [token, setToken] = useState(localStorage.getItem('token') || null);
  const [user, setUser] = useState(null);

  useEffect(() => {
    if (token) {
      try {
        const payload = jwtDecode(token);
        setUser({ name: payload.name, role: payload.role, email: payload.email });
      } catch { setUser(null); }
    } else setUser(null);
  }, [token]);

  if (!token) return (
    <NotificationProvider>
      <Login onLogin={(t)=>{ localStorage.setItem('token', t); setToken(t); }} />
    </NotificationProvider>
  );
  
  return (
    <NotificationProvider>
      <Dashboard token={token} user={user} onLogout={()=>{ localStorage.removeItem('token'); setToken(null); }} />
    </NotificationProvider>
  );
}
