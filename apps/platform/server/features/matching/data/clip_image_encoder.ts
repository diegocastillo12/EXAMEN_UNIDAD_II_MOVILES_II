import { createReadStream } from 'node:fs';
import { readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { join } from 'node:path';
import type { AutoProcessor, CLIPVisionModelWithProjection } from '@huggingface/transformers';
import { matchModel, MatchFailure, unitEmbedding } from '../../../../shared/features/matching/domain/matching.ts';
import type { ImageEncoder } from '../../../../shared/features/matching/domain/matching.ts';

// Only immutable model weights are shared; no photos, actors or user state are cached.
// Model preparation is explicit; requests never download executable weights from the Internet.
type Resources = { processor: Awaited<ReturnType<typeof AutoProcessor.from_pretrained>>; model: CLIPVisionModelWithProjection };
let resources: Promise<Resources> | null = null;
let occupied = false;
async function verify(directory:string) {
  const files:Record<string,string>={
    'config.json':'493ef57ff783e42d1530c91b53469b7fdf8db8a9c1408e86998fcb7899a4f495',
    'preprocessor_config.json':'6f638fb9401a6d6296feff533ee7efe657b787c49f954f82f5906b36ef2a1b1f',
    'onnx/vision_model_quantized.onnx':'583fd1110a514667812fee7d684952aaf82a99b959760c8d7dca7e0ab9839299',
  };
  const manifest=JSON.parse(await readFile(join(directory,'match-model.json'),'utf8'));
  if(manifest.version!==matchModel.version||manifest.revision!==matchModel.revision)throw new MatchFailure('unavailable');
  for(const [file,expected]of Object.entries(files)){
    const hash=createHash('sha256');for await(const bytes of createReadStream(join(directory,file)))hash.update(bytes);
    if(hash.digest('hex')!==expected)throw new MatchFailure('unavailable');
  }
}
async function load(): Promise<Resources> {
  if (!process.env.MATCH_MODEL_DIRECTORY) throw new MatchFailure('unavailable');
  const directory = process.env.MATCH_MODEL_DIRECTORY;
  resources ??= verify(directory).then(async()=>{
    const { env, AutoProcessor, CLIPVisionModelWithProjection } = await import('@huggingface/transformers');
    env.allowRemoteModels = false;
    env.allowLocalModels = true;
    return Promise.all([
      AutoProcessor.from_pretrained(directory, { local_files_only: true }),
      CLIPVisionModelWithProjection.from_pretrained(directory, { local_files_only: true, dtype: 'q8', device: 'cpu' }),
    ]);
  }).then(([processor, model]) => ({ processor, model })).catch(() => { resources = null; throw new MatchFailure('unavailable'); });
  return resources;
}
export class ClipImageEncoder implements ImageEncoder {
  async encode(bytes: Uint8Array): Promise<readonly number[]> {
    if (occupied) throw new MatchFailure('busy');
    if (!bytes.length || bytes.length > 2097152) throw new MatchFailure('unavailable');
    occupied = true;
    try {
      // Listing searches/reviewing cached results must not load native image code.
      const { default: sharp } = await import('sharp');
      const input = sharp(bytes, { limitInputPixels: 4000000, failOn: 'warning', animated: false });
      const metadata = await input.metadata();
      if (metadata.format !== 'jpeg' || (metadata.pages || 1) !== 1) throw new MatchFailure('unavailable');
      const { data, info } = await input.rotate().resize(224,224,{fit:'cover'}).removeAlpha().toColourspace('srgb').raw().toBuffer({resolveWithObject:true});
      const { processor, model } = await load();
      const { RawImage } = await import('@huggingface/transformers');
      const image = new RawImage(new Uint8ClampedArray(data), info.width, info.height, info.channels);
      const output = await model(await processor(image));
      const vector = Array.from(output.image_embeds.data, x => Number(x));
      if (vector.length !== matchModel.dimensions) throw new MatchFailure('unavailable');
      return unitEmbedding(vector);
    } catch (error) { throw error instanceof MatchFailure ? error : new MatchFailure('unavailable'); }
    finally { occupied = false; }
  }
}
