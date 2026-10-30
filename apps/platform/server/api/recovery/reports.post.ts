import { recovery,recoveryError,recoveryForm } from '../../utils/recovery';
export default defineEventHandler(async event => { try { const model = await recovery(event), body = await recoveryForm(event); return await model.publish.execute(body.draft,body.photos); } catch(e) { return recoveryError(event,e); } });
