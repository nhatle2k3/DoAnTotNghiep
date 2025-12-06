// If VITE_API_BASE is provided, use it. Otherwise derive the API base
// from the current page origin so mobile devices can reach the API when
// they open the client via the computer's IP address.
const API_BASE = import.meta.env.VITE_API_BASE || `${location.protocol}//${location.hostname}:4000/api`;

export async function api(path, { method='GET', body, token } = {}) {
  const res = await fetch(`${API_BASE}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { 'Authorization': `Bearer ${token}` } : {})
    },
    body: body ? JSON.stringify(body) : undefined
  });
  if (!res.ok) {
    let msg = 'Request failed';
    try { const j = await res.json(); msg = j.error || msg; } catch {}
    throw new Error(msg);
  }
  return res.json();
}
