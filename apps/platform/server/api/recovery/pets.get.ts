import { recovery,recoveryError } from '../../utils/recovery';
export default defineEventHandler(async event => { try { return await (await recovery(event)).pets.execute(); } catch(e) { return recoveryError(event,e); } });
