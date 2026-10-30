import { recovery,recoveryError } from '../../utils/recovery';
export default defineEventHandler(async event => { try { const model = await recovery(event); return await model.save.execute(await readBody(event)); } catch(e) { return recoveryError(event,e); } });
