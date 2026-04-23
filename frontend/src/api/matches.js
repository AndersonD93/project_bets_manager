export async function getMatches(url, token) {
  const res = await fetch(url, {
    headers: { Authorization: token, 'Content-Type': 'application/json' },
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  return res.json();
}

export async function createMatch(url, token, { match_id, teams, match_date }) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { Authorization: token, 'Content-Type': 'application/json' },
    body: JSON.stringify({ match_id, teams, match_date }),
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  return res.json();
}

export async function loadMatchesFromApi(url, token, { competition_id, matchday }) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { Authorization: token, 'Content-Type': 'application/json' },
    body: JSON.stringify({ competition_id, matchday }),
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  return res.json();
}
