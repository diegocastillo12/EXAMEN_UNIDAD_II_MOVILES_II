import sharp from 'sharp';
import { SightingFailure } from '../../../../shared/features/sightings/domain/sighting.ts';
export async function processEvidence(input: Uint8Array | null): Promise<Buffer | null> {
  if (!input) return null;
  if (input.length > 8388608) throw new SightingFailure('photo');
  const header = Buffer.from(input.subarray(0, 12));
  const supported = (header[0] === 0xff && header[1] === 0xd8 && header[2] === 0xff) ||
    header.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])) ||
    (header.toString('ascii', 0, 4) === 'RIFF' && header.toString('ascii', 8, 12) === 'WEBP');
  if (!supported) throw new SightingFailure('photo');
  try {
    const image = sharp(input, { limitInputPixels: 24000000, failOn: 'warning', animated: false });
    const metadata = await image.metadata();
    if (!['jpeg', 'png', 'webp'].includes(metadata.format || '') || (metadata.pages || 1) !== 1) throw Error();
    const bytes = await image.rotate().resize({ width: 1280, height: 1280, fit: 'inside', withoutEnlargement: true })
      .flatten({ background: '#ffffff' }).jpeg({ quality: 78 }).timeout({ seconds: 5 }).toBuffer();
    if (bytes.length > 1048576) throw Error();
    return bytes;
  } catch { throw new SightingFailure('photo'); }
}
