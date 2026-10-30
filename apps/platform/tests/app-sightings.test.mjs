import assert from 'node:assert/strict';
import {test} from 'node:test';
import {verifiedSightingReporter, SightingAuthenticationFailure} from '../server/features/sightings/data/app_sighting_auth.ts';
import {SupabaseSightingDataSource} from '../server/features/sightings/data/supabase_sighting_data_source.ts';
test('App identity comes from Auth validation, rejects invalid/anonymous/expired sessions and bounds output',async()=>{
 const config={url:'https://backend.example.test',key:'server-placeholder'};const token='Bearer '+ 'a'.repeat(30);const id='11111111-1111-4111-8111-111111111125';
 assert.equal(await verifiedSightingReporter(config,token,async(url,options)=>{assert.equal(url,config.url+'/auth/v1/user');assert.equal(options.headers.Authorization,token);return Response.json({id});}),id);
 for(const response of [new Response('',{status:401}),Response.json({id,is_anonymous:true}),Response.json({id:'bad'}),new Response('a'.repeat(65537))]){
  await assert.rejects(verifiedSightingReporter(config,token,async()=>response),SightingAuthenticationFailure);
 }
 await assert.rejects(verifiedSightingReporter(config,'fake',async()=>{throw Error('must not call');}),SightingAuthenticationFailure);
});
test('Authenticated adapter sends only verified reporter and case to app RPC',async()=>{
 const source=new SupabaseSightingDataSource({url:'https://backend.example.test',key:'server-placeholder'},async(url,options)=>{
  assert.equal(url,'https://backend.example.test/rest/v1/rpc/submit_app_sighting');
  assert.deepEqual(JSON.parse(options.body),{p_report:{id:'report'},p_case:'case',p_source:'lost',p_reporter:'verified'});
  return Response.json({id:'report'});
 },'submit_app_sighting',({p_slug,...rest})=>({...rest,p_case:'case',p_source:'lost',p_reporter:'verified'}));
 assert.deepEqual(await source.submit({p_slug:'hidden',p_report:{id:'report'}}),{id:'report'});
});
