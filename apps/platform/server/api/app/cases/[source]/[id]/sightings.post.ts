import { createHash, createHmac } from 'node:crypto';
import { configuration } from '../../../../../infrastructure/config';
import { sightingRequest } from '../../../../../infrastructure/sighting_request';
import { SightingAuthenticationFailure, verifiedSightingReporter } from '../../../../../features/sightings/data/app_sighting_auth';
import { SupabaseSightingRepository } from '../../../../../features/sightings/data/supabase_sighting_repository';
import { SupabaseSightingDataSource } from '../../../../../features/sightings/data/supabase_sighting_data_source';
import { SubmitSighting, SightingFailure } from '../../../../../../shared/features/sightings/domain/sighting';
export default defineEventHandler(async event => {
  try {
    const config = configuration(process.env);
    const reporter = await verifiedSightingReporter(config, getHeader(event, 'authorization') || '');
    const source = getRouterParam(event, 'source') || ''; const id = getRouterParam(event, 'id') || '';
    if (!['lost', 'found'].includes(source) || !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(id)) throw new SightingFailure('closed');
    const actor = createHmac('sha256', config.key).update(`app-sighting:${reporter}`).digest('hex');
    const target = createHash('sha256').update(`${source}:${id}`).digest('hex');
    const data = new SupabaseSightingDataSource(config, fetch, 'submit_app_sighting', payload => {
      const {p_slug: _, ...rest} = payload;
      return {...rest, p_source: source, p_case: id, p_reporter: reporter};
    });
    return await new SubmitSighting(new SupabaseSightingRepository(data, actor)).execute(target, await sightingRequest(event.node.req));
  } catch (error) {
    if (error instanceof SightingAuthenticationFailure) { setResponseStatus(event, 401); return {error: 'forbidden'}; }
    const failure = error instanceof SightingFailure ? error : new SightingFailure('unavailable');
    setResponseStatus(event, failure.kind === 'blocked' ? 423 : failure.kind === 'invalid' ? 400 : failure.kind === 'photo' ? 422 : failure.kind === 'rate_limited' ? 429 : ['closed', 'conflict'].includes(failure.kind) ? 409 : 503);
    setHeader(event, 'Connection', 'close');
    if (failure.kind === 'rate_limited') setHeader(event, 'Retry-After', 600);
    return {error: failure.kind, fields: failure.fields};
  }
});
