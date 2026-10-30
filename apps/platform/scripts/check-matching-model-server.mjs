import assert from'node:assert/strict';
import{resolve}from'node:path';
import{matchingFixture,lost}from'../tests/matching_fixture.mjs';
const server=await matchingFixture({uncached:true,modelDirectory:resolve('.cache/matching/clip-vit-b32-d15189d-q8-v1')});
try{
 const search=()=>fetch(server.origin+'/api/app/matching/search',{method:'POST',headers:{Authorization:'Bearer '+'o'.repeat(30),'Content-Type':'application/json'},body:JSON.stringify({source:'lost',id:lost})});
 const first=await search();assert.equal(first.status,200);const result=await first.json();assert.equal(result.complete,true);assert.equal(result.candidates.length,1);assert.equal(server.indexed.size,2);
 for(const v of server.indexed.values()){assert.equal(v.length,512);assert.ok(Math.abs(Math.hypot(...v)-1)<1e-6);}
 const again=await search();assert.equal(again.status,200);assert.equal(server.indexed.size,2);
 console.log('Built server + real local CLIP + backend fixture with cached embeddings: 2 image embeddings, normalization, ranking and cached retry PASS. Synthetic canary images do not evaluate animal identity accuracy.');
}finally{await server.close();}
