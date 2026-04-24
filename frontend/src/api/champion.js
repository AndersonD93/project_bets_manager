export async function getChampionData(url, token, user_id) {
  const res = await fetch(`${url}?user_id=${encodeURIComponent(user_id)}`, {
    headers: { Authorization: token, 'Content-Type': 'application/json' },
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  const data = await res.json();
  return typeof data.body === 'string' ? JSON.parse(data.body) : (data.body ?? data);
}

export async function putChampion(url, token, { user_id, country }) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { Authorization: token, 'Content-Type': 'application/json' },
    body: JSON.stringify({ user_id, country }),
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  const data = await res.json();
  return typeof data.body === 'string' ? JSON.parse(data.body) : (data.body ?? data);
}

export async function setChampionConfig(url, token, { insert_blocked, update_blocked }) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { Authorization: token, 'Content-Type': 'application/json' },
    body: JSON.stringify({ insert_blocked, update_blocked }),
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  const data = await res.json();
  return typeof data.body === 'string' ? JSON.parse(data.body) : (data.body ?? data);
}

export async function getTournamentChampion(url, token) {
  const res = await fetch(url, {
    headers: { Authorization: token, 'Content-Type': 'application/json' },
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  const data = await res.json();
  return typeof data.body === 'string' ? JSON.parse(data.body) : (data.body ?? data);
}

export async function setTournamentChampion(url, token, country) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { Authorization: token, 'Content-Type': 'application/json' },
    body: JSON.stringify({ country }),
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  const data = await res.json();
  return typeof data.body === 'string' ? JSON.parse(data.body) : (data.body ?? data);
}
