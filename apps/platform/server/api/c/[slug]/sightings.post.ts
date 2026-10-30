import { SightingFailure } from '../../../../shared/features/sightings/domain/sighting';
import { sightingWriter } from '../../../utils/sightings';
import { sightingRequest } from '../../../infrastructure/sighting_request';
export default defineEventHandler(async event => {
  try {
    const slug = getRouterParam(event, 'slug') || '';
    const draft = await sightingRequest(event.node.req);
    return await sightingWriter(event.context.readerPeer || '').execute(slug, draft);
  } catch (error) {
    const failure = error instanceof SightingFailure ? error : new SightingFailure('unavailable');
    setResponseStatus(event, failure.kind === 'invalid' ? 400 : failure.kind === 'photo' ? 422 : failure.kind === 'rate_limited' ? 429 : ['closed', 'conflict'].includes(failure.kind) ? 409 : 503);
    if (failure.kind === 'rate_limited') setHeader(event, 'Retry-After', 600);
    setHeader(event, 'Connection', 'close');
    return { error: failure.kind, fields: failure.fields };
  }
});
