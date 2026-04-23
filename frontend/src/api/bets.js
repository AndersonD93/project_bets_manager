export async function placeBet(url, token, { user_id, match_id, bet_result, exact_score }) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { Authorization: token, 'Content-Type': 'application/json' },
    body: JSON.stringify({ user_id, match_id, bet_result, exact_score }),
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  return res.json();
}
