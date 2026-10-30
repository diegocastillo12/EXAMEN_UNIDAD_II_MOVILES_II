import { credentials, credentialError } from '../../../utils/credentials';
import { moderationBody } from '../../../utils/moderation';
import { CredentialFailure } from '../../../../shared/features/access/domain/credentials';
export default defineEventHandler(async event => {
  try {
    const body = await moderationBody(event).catch(() => { throw new CredentialFailure('invalid_request'); }), service = credentials(event);
    const field = (key: string) => { if (typeof body[key] !== 'string') throw new CredentialFailure('invalid_request'); return body[key] as string; };
    const kind = () => { const value = field('kind'); if (value !== 'registration' && value !== 'recovery') throw new CredentialFailure('conflict'); return value; };
    let result: unknown;
    switch (getRouterParam(event, 'action')) {
      case 'register': service.assertGuest(); result = await service.register.execute(field('name'), field('email'), field('password'), field('confirmation')); break;
      case 'recover': service.assertGuest(); result = { progress: await service.recover.execute(field('email')) }; break;
      case 'verify': service.assertGuest(); result = await service.verify.execute(kind(), field('id'), field('code')); break;
      case 'resend': {
        const progress = await service.read.execute();
        if (!progress) throw new CredentialFailure('expired');
        if (progress.id !== field('id') || progress.kind !== kind()) throw new CredentialFailure('conflict');
        result = { progress: await service.resend.execute(progress) }; break;
      }
      case 'reset': service.assertGuest(); await service.reset.execute(field('id'), field('password'), field('confirmation')); result = { updated: true }; break;
      case 'cancel': await service.cancel.execute(); result = { cancelled: true }; break;
      default: throw new CredentialFailure('conflict');
    }
    service.save(); return result;
  } catch (error) { return credentialError(event, error); }
});
