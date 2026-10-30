import type { IncomingMessage } from 'node:http';
import { SightingFailure } from '../../shared/features/sightings/domain/sighting.ts';
import type { SightingDraft } from '../../shared/features/sightings/domain/sighting.ts';
export const maxSightingBody = 9 * 1024 * 1024;
export async function sightingRequest(request: IncomingMessage): Promise<SightingDraft> {
  const contentType = request.headers['content-type'] || '';
  if (!/^multipart\/form-data;\s*boundary=/.test(contentType)) throw new SightingFailure('invalid');
  if (Number(request.headers['content-length']) > maxSightingBody) throw new SightingFailure('invalid');
  const body = await new Promise<Buffer>((resolve, reject) => {
    const chunks: Buffer[] = []; let bytes = 0;
    const clean = () => { clearTimeout(timer); request.off('data', data); request.off('end', end); request.off('error', fail); request.off('aborted', fail); };
    const fail = () => { clean(); reject(new SightingFailure('invalid')); };
    const data = (chunk: Buffer) => { bytes += chunk.length; if (bytes > maxSightingBody) { request.pause(); fail(); } else chunks.push(chunk); };
    const end = () => { clean(); resolve(Buffer.concat(chunks)); };
    const timer = setTimeout(() => { request.pause(); fail(); }, 15000);
    request.on('data', data); request.once('end', end); request.once('error', fail); request.once('aborted', fail);
  });
  try {
    const form = await new Response(new Uint8Array(body), { headers: { 'Content-Type': contentType } }).formData();
    if (form.getAll('report').length !== 1 || form.getAll('photo').length > 1 || [...form.keys()].some(key => !['report', 'photo'].includes(key))) throw Error();
    const raw = form.get('report'); if (typeof raw !== 'string' || raw.length > 4096) throw Error();
    const value = JSON.parse(raw);
    if (!value || typeof value !== 'object' || Array.isArray(value) || typeof value.observedAt !== 'string' || value.observedAt.length > 40 || !/^\d{4}-\d{2}-\d{2}T.*Z$/.test(value.observedAt) || new Date(value.observedAt).toISOString() !== value.observedAt || typeof value.id !== 'string') throw Error();
    const photo = form.get('photo'); if (typeof photo === 'string') throw Error();
    return { id: value.id, observedAt: value.observedAt, point: value.point, comment: value.comment, photo: photo ? new Uint8Array(await photo.arrayBuffer()) : null };
  } catch { throw new SightingFailure('invalid'); }
}
