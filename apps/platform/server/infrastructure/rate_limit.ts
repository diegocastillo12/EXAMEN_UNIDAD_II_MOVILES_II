import { isIP } from 'node:net';
import type { IncomingMessage } from 'node:http';
const normalize = (ip = '') => ip.startsWith('::ffff:') ? ip.slice(7) : ip;
export function clientAddress(request: IncomingMessage, trustedProxies: string[]) {
  const peer = normalize(request.socket?.remoteAddress);
  if (!trustedProxies.includes(peer)) return peer;
  const header = request.headers['x-forwarded-for'];
  const forwarded = typeof header === 'string' ? normalize(header.split(',').at(-1)?.trim()) : '';
  return isIP(forwarded) ? forwarded : peer;
}
export class RateLimit {
  readonly clients = new Map<string, { expires: number; count: number }>();
  private lastSweep = 0;
  constructor(private readonly options = { limit: 60, windowMs: 60000, maxClients: 10000, now: Date.now }) {}
  allow(client: string) {
    const now = this.options.now();
    if (now - this.lastSweep >= 1000) {
      for (const [key, value] of this.clients) if (value.expires <= now) this.clients.delete(key);
      this.lastSweep = now;
    }
    let entry = this.clients.get(client);
    if (!entry || entry.expires <= now) {
      if (!entry && this.clients.size >= this.options.maxClients) return false;
      entry = { expires: now + this.options.windowMs, count: 0 }; this.clients.set(client, entry);
    }
    return ++entry.count <= this.options.limit;
  }
}
