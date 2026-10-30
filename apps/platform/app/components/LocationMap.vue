<script setup lang="ts">
import type { Map as LeafletMap, Marker, Circle, GridLayer, Coords, DoneCallback } from 'leaflet';
import 'leaflet/dist/leaflet.css';
type MapCoordinate = { latitude: number; longitude: number };
const props = withDefaults(defineProps<{ center: MapCoordinate; point: MapCoordinate | null; disabled: boolean; invalid: boolean; radiusMeters?: number }>(), { radiusMeters: 0 });
const emit = defineEmits<{ choose: [point: MapCoordinate]; failed: [retry: () => void] }>();
const config = useRuntimeConfig();
const target = useTemplateRef('mapCanvas'); const ready = ref(false);
let map: LeafletMap | undefined; let marker: Marker | undefined; let radius: Circle | undefined; let tiles: GridLayer | undefined; let disposed = false; let failed = false;
let resizeObserver: ResizeObserver | undefined;
function choose(latitude: number, longitude: number) {
  if (props.disabled || failed || !ready.value) return;
  emit('choose', { latitude: Math.max(-85, Math.min(85, latitude)), longitude: ((longitude + 180) % 360 + 360) % 360 - 180 });
}
function retry() { failed = false; tiles?.redraw(); }
async function start() {
  try {
    const template = String(config.public.mapTileUrl || '');
    const source = new URL(template);
    if (source.protocol !== 'https:' || source.hostname !== 'basemaps.cartocdn.com' || !source.pathname.includes('/light_all/')) throw new Error('map_not_configured');
    const L = await import('leaflet');
    if (disposed || !target.value) return;
    map = L.map(target.value, { attributionControl: false, zoomControl: false, minZoom: 3, maxZoom: 18, maxBounds: [[-85, -540], [85, 540]], fadeAnimation: false, zoomAnimation: false, markerZoomAnimation: false })
      .setView([props.point?.latitude ?? props.center.latitude, props.point?.longitude ?? props.center.longitude], 12);
    // GridLayer's public adapter avoids TileLayer's inline data-GIF cancellation,
    // keeping the existing strict CSP without allowing data: images.
    class LocationTileLayer extends L.GridLayer {
      override createTile(coords: Coords, done: DoneCallback) {
        const image = document.createElement('img'); image.alt = ''; image.referrerPolicy = 'no-referrer';
        image.onload = () => done?.(undefined, image);
        image.onerror = () => done?.(new Error('map_tile_unavailable'), image);
        image.src = template.replace('{z}', String(coords.z)).replace('{x}', String(coords.x)).replace('{y}', String(coords.y));
        return image;
      }
    }
    tiles = new LocationTileLayer({ tileSize: 256, maxZoom: 19 });
    tiles.on('tileunload', event => { const image = event.tile as HTMLImageElement; image.onload = null; image.onerror = null; image.removeAttribute('src'); });
    tiles.on('tileerror', () => { if (!failed && !disposed) { failed = true; emit('failed', retry); } });
    tiles.addTo(map);
    map.on('click', event => choose(event.latlng.lat, event.latlng.lng));
    // Same centered 36px Material location_on glyph as ZoneMapPicker (not tip-anchored).
    marker = L.marker([0, 0], { interactive: false, keyboard: false, icon: L.icon({ iconUrl: '/map-location-pin.svg', iconSize: [36, 36], iconAnchor: [18, 18], className: 'location-map-pin' }) });
    radius = L.circle([0, 0], { radius: props.radiusMeters, color: '#111111', weight: 2, opacity: 1, fillColor: '#111111', fillOpacity: 34 / 255, interactive: false });
    sync(); syncInteraction(); ready.value = true;
    resizeObserver = new ResizeObserver(() => map?.invalidateSize({ animate: false, pan: false }));
    resizeObserver.observe(target.value);
  } catch { if (!disposed) emit('failed', start); }
}
function sync() {
  if (!map || !marker || !radius) return;
  if (props.point) {
    const position: [number, number] = [props.point.latitude, props.point.longitude];
    if (props.radiusMeters > 0) radius.setLatLng(position).setRadius(props.radiusMeters).addTo(map);
    else radius.remove();
    marker.setLatLng(position).addTo(map);
    map.panTo(position, { animate: false });
  } else { marker.remove(); radius.remove(); }
}
function syncInteraction() {
  if (!map) return;
  for (const handler of [map.dragging, map.touchZoom, map.doubleClickZoom, map.scrollWheelZoom, map.boxZoom, map.keyboard]) {
    if (props.disabled) handler.disable(); else handler.enable();
  }
}
function chooseCenter() { if (map) choose(map.getCenter().lat, map.getCenter().lng); }
watch([() => props.point, () => props.radiusMeters], sync);
watch(() => props.disabled, syncInteraction);
onMounted(start);
onBeforeUnmount(() => { disposed = true; resizeObserver?.disconnect(); map?.remove(); });
</script>
<template>
  <div class="location-map-wrap" :class="{ invalid }">
    <div ref="mapCanvas" class="location-map" role="region" aria-label="Mapa para elegir una ubicación" :aria-invalid="invalid" :aria-disabled="disabled" @keydown.enter.prevent="chooseCenter" @keydown.space.prevent="chooseCenter" />
    <div class="map-attribution" aria-label="Créditos del mapa">
      <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noreferrer noopener">© OpenStreetMap contributors</a>
      <a href="https://carto.com/attribution/" target="_blank" rel="noreferrer noopener">© CARTO</a>
    </div>
    <div v-if="!ready" class="location-map-placeholder shape" role="status" aria-label="Preparando mapa" />
  </div>
</template>
