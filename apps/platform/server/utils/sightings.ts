import { createHmac } from 'node:crypto';
import { configuration } from '../infrastructure/config';
import { SupabaseSightingRepository } from '../features/sightings/data/supabase_sighting_repository';
import { SupabaseSightingDataSource } from '../features/sightings/data/supabase_sighting_data_source';
import { SubmitSighting } from '../../shared/features/sightings/domain/sighting';
export function sightingWriter(peer: string) {
  const config = configuration(process.env);
  const hash = createHmac('sha256', config.key).update(`public-sighting:${peer}`).digest('hex');
  return new SubmitSighting(new SupabaseSightingRepository(new SupabaseSightingDataSource(config), hash));
}
