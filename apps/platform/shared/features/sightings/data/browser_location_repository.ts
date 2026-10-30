import { SightingFailure } from '../domain/sighting.ts';
import type { SightingPoint, SightingLocationRepository } from '../domain/sighting.ts';
export class BrowserSightingLocationRepository implements SightingLocationRepository {
  async current(): Promise<SightingPoint> {
    if (typeof navigator === 'undefined' || !navigator.geolocation) throw new SightingFailure('location');
    return new Promise((resolve, reject) => navigator.geolocation.getCurrentPosition(
      value => resolve({ latitude: value.coords.latitude, longitude: value.coords.longitude, accuracy: value.coords.accuracy, source: 'gps' }),
      () => reject(new SightingFailure('location')), { enableHighAccuracy: false, timeout: 10000, maximumAge: 0 },
    ));
  }
}
