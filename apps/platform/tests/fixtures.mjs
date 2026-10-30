export const slug = 'a'.repeat(64);
export const photo = { bucket: 'pet-photo-renditions', path: '11111111-1111-4111-8111-111111111199/bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb99/cccccccc-cccc-4ccc-8ccc-cccccccccc99.jpg' };
export const rawActive = () => ({ state: 'active', kind: 'lost', name: 'Luna', species: 'dog', species_detail: null,
  size: 'small', sex: 'female', traits: 'Pelaje blanco y una mancha negra en la oreja izquierda.',
  occurred_at: '2026-10-15T17:30:00.000Z', area: { latitude: -12.05, longitude: -77.04 }, photo_objects: [photo] });
export const active = () => ({ state: 'active', kind: 'lost', name: 'Luna', species: 'dog', speciesDetail: null,
  size: 'small', sex: 'female', traits: rawActive().traits, occurredAt: rawActive().occurred_at,
  area: rawActive().area, photoCount: 1, revision: 'b'.repeat(64) });
