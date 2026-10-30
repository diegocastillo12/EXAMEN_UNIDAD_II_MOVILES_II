import type { H3Event } from 'h3';
import { account, accountCookie, accountError } from './account';
import { AccessFailure } from '../../shared/features/access/domain/access';
import { ExploreCases, ReadMyPets, SaveMyPet, AddPetPhoto, ReadOpenSearches, PublishRecoveryReport, ReadCasePublication, RecoveryFailure } from '../../shared/features/recovery/domain/recovery';
import { moderationConfiguration } from '../infrastructure/moderation_session';
import { openAccountSession } from '../infrastructure/account_session';
import { RecoverySource } from '../features/recovery/data/recovery_source';
import { ServerRecoveryRepository } from '../features/recovery/data/server_recovery_repository';
export async function recovery(event: H3Event, photo = false) {
  const session = await account(event, !photo).access.session();
  if (!session.profile.onboardingCompleted) throw new AccessFailure('forbidden');
  const config = moderationConfiguration(process.env), privateSession = openAccountSession(getCookie(event,accountCookie),config.sessionSecret);
  if (!privateSession || privateSession.actor !== session.actor) throw new AccessFailure('unauthenticated');
  const repository = new ServerRecoveryRepository(new RecoverySource(config,privateSession.token),session.actor);
  return { repository,publication:new ReadCasePublication(repository),explore:new ExploreCases(repository),pets:new ReadMyPets(repository),save:new SaveMyPet(repository),photo:new AddPetPhoto(repository),targets:new ReadOpenSearches(repository),publish:new PublishRecoveryReport(repository) };
}
export function recoveryError(event: H3Event, e: unknown) {
  if (!(e instanceof RecoveryFailure)) return accountError(event,e);
  setResponseStatus(event,e.kind === 'blocked' ? 423 : e.kind === 'unauthenticated' ? 401 : e.kind === 'forbidden' ? 403 : e.kind === 'conflict' ? 409 : e.kind === 'invalid' || e.kind === 'photo' ? 422 : 503);
  return { error:e.kind };
}
export async function recoveryForm(event: H3Event) {
  const type = getHeader(event,'content-type') || '';
  if (!/^multipart\/form-data;\s*boundary=/.test(type)) throw new RecoveryFailure('invalid');
  // readRawBody alone does not bound chunked requests. Enforce the same cap
  // while streaming, including requests with no Content-Length.
  const request = event.node.req, max = 26 * 1024 * 1024;
  if (Number(getHeader(event,'content-length')) > max) throw new RecoveryFailure('invalid');
  const bytes = await new Promise<Buffer>((resolve,reject) => {
    const chunks: Buffer[] = []; let size = 0;
    const clean = () => { clearTimeout(timer); request.off('data',data); request.off('end',end); request.off('error',fail); request.off('aborted',fail); };
    const fail = () => { clean(); reject(new RecoveryFailure('invalid')); };
    const data = (chunk: Buffer) => { size += chunk.length; if (size > max) { request.pause(); fail(); } else chunks.push(chunk); };
    const end = () => { clean(); resolve(Buffer.concat(chunks)); };
    const timer = setTimeout(() => { request.pause(); fail(); },30000);
    request.on('data',data);request.once('end',end);request.once('error',fail);request.once('aborted',fail);
  });
  try {
    const form = await new Response(new Uint8Array(bytes),{ headers:{ 'Content-Type':type } }).formData();
    if (form.getAll('draft').length !== 1 || form.getAll('photo').length > 3 || [...form.keys()].some(k => !['draft','photo'].includes(k))) throw Error();
    const raw = form.get('draft'); if (typeof raw !== 'string' || raw.length > 8192) throw Error();
    const photos = []; for (const file of form.getAll('photo')) { if (typeof file === 'string' || file.size > 8388608) throw Error(); photos.push({ id:file.name,bytes:new Uint8Array(await file.arrayBuffer()) }); }
    return { draft:JSON.parse(raw),photos };
  } catch { throw new RecoveryFailure('invalid'); }
}
