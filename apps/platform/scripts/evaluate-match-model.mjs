import {readFile}from'node:fs/promises';
import{createHash}from'node:crypto';
import{resolve,dirname,relative,isAbsolute}from'node:path';
import sharp from'sharp';
import{ClipImageEncoder}from'../server/features/matching/data/clip_image_encoder.ts';
import{rankMatches,matchModel}from'../shared/features/matching/domain/matching.ts';
// Run only with an authorized local manifest. No scraping or upload is performed.
if(!process.argv[2])throw Error('Provide an authorized dataset manifest JSON');
const manifestPath=resolve(process.argv[2]),root=dirname(manifestPath),manifest=JSON.parse(await readFile(manifestPath,'utf8'));
if(typeof manifest.provenance!=='string'||!manifest.provenance.trim()||typeof manifest.license!=='string'||!Array.isArray(manifest.entries)||manifest.entries.length<2)throw Error('Dataset provenance, license and entries are required');
const identities=new Map(),hashes=new Set(),entries=[],encoder=new ClipImageEncoder();let latency=0;
for(const [index,entry]of manifest.entries.entries()){
 if(entry.authorized!==true||typeof entry.identity!=='string'||!entry.identity||!['test','development'].includes(entry.split)||!['query','gallery'].includes(entry.role)||!['dog','cat','other'].includes(entry.species))throw Error('Every entry requires explicit authorization, identity, split, role and species');
 if(identities.has(entry.identity)&&identities.get(entry.identity)!==entry.split)throw Error('Identity leakage between development and test splits');identities.set(entry.identity,entry.split);
 const path=resolve(root,entry.file),rel=relative(root,path);if(rel.startsWith('..')||isAbsolute(rel))throw Error('Images must remain inside the manifest directory');
 const bytes=await readFile(path),hash=createHash('sha256').update(bytes).digest('hex');if(hashes.has(hash))throw Error('Repeated image bytes are not an independent identity evaluation');hashes.add(hash);
 if(!Number.isFinite(Date.parse(entry.occurredAt))||!Number.isFinite(entry.latitude)||Math.abs(entry.latitude)>85||!Number.isFinite(entry.longitude)||Math.abs(entry.longitude)>180)throw Error('Valid event time and approximate geography are required');
 const jpeg=await sharp(bytes,{limitInputPixels:24000000,animated:false}).rotate().resize(1600,1600,{fit:'inside'}).flatten({background:'#fff'}).jpeg().toBuffer();
 const start=performance.now(),embedding=await encoder.encode(jpeg);latency+=performance.now()-start;
 entries.push({identity:entry.identity,split:entry.split,role:entry.role,ref:{source:entry.role==='query'?'lost':'found',id:`a0000000-0000-4000-8000-${String(index+1).padStart(12,'0')}`},revision:'a'.repeat(32),name:'',species:entry.species,occurredAt:entry.occurredAt,latitude:entry.latitude,longitude:entry.longitude,photos:[{id:'evaluation',path:'local',hash,embedding}]});
}
const queries=entries.filter(e=>e.split==='test'&&e.role==='query'),gallery=entries.filter(e=>e.split==='test'&&e.role==='gallery');
if(!queries.length||gallery.length<6)throw Error('Evaluation requires test queries and at least six gallery entries including distractors');
let positiveQueries=0,recallHits=0,wrongTop1=0,negativeQueries=0,negativesWithSuggestions=0;
for(const query of queries){
 const ranked=rankMatches(query,gallery),hasPair=gallery.some(c=>c.identity===query.identity&&c.species===query.species);
 if(hasPair){positiveQueries++;if(ranked.some(r=>r.item.identity===query.identity))recallHits++;if(ranked[0]?.item.identity!==query.identity)wrongTop1++;}
 else{negativeQueries++;if(ranked.length)negativesWithSuggestions++;}
}
console.log(JSON.stringify({model:matchModel,rankingVersion:'visual85-geography10-time5-v1',testIdentities:new Set(entries.filter(e=>e.split==='test').map(e=>e.identity)).size,positiveQueries,recallAt5:positiveQueries?recallHits/positiveQueries:null,wrongTop1,negativeQueries,negativesWithSuggestions,meanEncodingMs:Math.round(latency/entries.length),exploratorySampleSufficient:new Set(entries.filter(e=>e.split==='test').map(e=>e.identity)).size>=50,limitations:'No calibrated identity probability or automatic notification threshold. Operator must review dataset quality and results before activation.'},null,2));
