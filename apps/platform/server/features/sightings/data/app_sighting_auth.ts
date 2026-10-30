export class SightingAuthenticationFailure extends Error {}
/** Never decode a JWT as proof of identity. Auth verifies signature, expiry and user. */
export async function verifiedSightingReporter(config: {url: string; key: string}, authorization: string, fetcher: typeof fetch = fetch): Promise<string> {
  if (!/^Bearer [A-Za-z0-9._-]{20,8192}$/.test(authorization)) throw new SightingAuthenticationFailure();
  const response = await fetcher(`${config.url}/auth/v1/user`, {
    headers: {apikey: config.key, Authorization: authorization}, redirect: 'error', cache: 'no-store', signal: AbortSignal.timeout(10000),
  });
  if (!response.ok) { await response.body?.cancel(); throw new SightingAuthenticationFailure(); }
  const reader = response.body?.getReader(); if (!reader) throw new SightingAuthenticationFailure();
  const chunks: Uint8Array[] = []; let length = 0;
  try { while (true) { const next = await reader.read(); if (next.done) break; length += next.value.length; if (length > 65536) throw new SightingAuthenticationFailure(); chunks.push(next.value); } }
  finally { await reader.cancel().catch(() => {}); }
  const value = JSON.parse(Buffer.concat(chunks).toString('utf8'));
  if (typeof value.id !== 'string' || !/^[0-9a-f-]{36}$/.test(value.id) || value.is_anonymous === true) throw new SightingAuthenticationFailure();
  return value.id;
}
