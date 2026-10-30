import {recovery,recoveryError}from'../../utils/recovery';
export default defineEventHandler(async event=>{try{const model=await recovery(event);const body=await readBody(event);return await model.publication.execute(body.source,body.id);}catch(e){return recoveryError(event,e);}});
