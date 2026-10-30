import { mkdir, writeFile, readFile, rename } from 'node:fs/promises';
import { resolve, join } from 'node:path';
import { createHash } from 'node:crypto';

// Explicit operator action. No user images are uploaded and no inference API is used.
const revision='d15189d7028b43f1d3e65039190477f6af591c2a';
const directory=resolve(process.argv[2] || '.cache/matching/clip-vit-b32-d15189d-q8-v1');
const files=['config.json','preprocessor_config.json','onnx/vision_model_quantized.onnx'];
const hashes={
 'config.json':'493ef57ff783e42d1530c91b53469b7fdf8db8a9c1408e86998fcb7899a4f495',
 'preprocessor_config.json':'6f638fb9401a6d6296feff533ee7efe657b787c49f954f82f5906b36ef2a1b1f',
 'onnx/vision_model_quantized.onnx':'583fd1110a514667812fee7d684952aaf82a99b959760c8d7dca7e0ab9839299',
};
const manifest={model:'Xenova/clip-vit-base-patch32',revision,version:'clip-vit-b32-d15189d-q8-v1',files:{}};
for(const file of files){
 const expected=hashes[file];
 const target=join(directory,file);
 await mkdir(resolve(target,'..'),{recursive:true});
 let bytes;
 try {bytes=await readFile(target);if(expected&&createHash('sha256').update(bytes).digest('hex')!==expected)bytes=null;}catch{bytes=null;}
 if(!bytes){
  const response=await fetch(`https://huggingface.co/Xenova/clip-vit-base-patch32/resolve/${revision}/${file}`,{signal:AbortSignal.timeout(300000)});
  if(!response.ok)throw Error(`Model download failed: ${file}`);
  const reader=response.body.getReader(),chunks=[];let size=0;
  try{while(true){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>100000000)throw Error('Model too large');chunks.push(value);}}finally{await reader.cancel();}
  bytes=Buffer.concat(chunks);
  if(expected&&createHash('sha256').update(bytes).digest('hex')!==expected)throw Error('Model checksum mismatch');
  await writeFile(target+'.partial',bytes);await rename(target+'.partial',target);
 }
 manifest.files[file]=createHash('sha256').update(bytes).digest('hex');
 console.log(`Verified ${file}: ${bytes.length} bytes`);
}
await writeFile(join(directory,'match-model.json'),JSON.stringify(manifest,null,2)+'\n');
console.log(`MATCH_MODEL_DIRECTORY=${directory}`);
