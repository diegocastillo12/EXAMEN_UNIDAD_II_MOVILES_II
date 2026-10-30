import { HttpSightingRepository } from '#shared/features/sightings/data/http_sighting_repository';
import { SubmitSighting, LocateSighting } from '#shared/features/sightings/domain/sighting';
import { BrowserSightingLocationRepository } from '#shared/features/sightings/data/browser_location_repository';
import { SightingViewModel } from '#shared/features/sightings/presentation/sighting_view_model';
export default defineNuxtPlugin(() => ({ provide: {
  sightingModel: (slug: string) => new SightingViewModel(new SubmitSighting(new HttpSightingRepository()), slug, new LocateSighting(new BrowserSightingLocationRepository())),
} }));
