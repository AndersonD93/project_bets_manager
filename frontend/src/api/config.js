const API_URL = import.meta.env.VITE_API_URL;

export async function getSecrets() {
  const res = await fetch(`${API_URL}/get_secret`);
  if (!res.ok) throw new Error(`Error ${res.status}`);
  const data = await res.json();
  return typeof data.body === 'string' ? JSON.parse(data.body) : data.body ?? data;
}
