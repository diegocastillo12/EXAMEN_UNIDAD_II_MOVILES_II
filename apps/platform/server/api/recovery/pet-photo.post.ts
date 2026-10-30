import { recovery,recoveryError,recoveryForm } from '../../utils/recovery';
import { RecoveryFailure } from '../../../shared/features/recovery/domain/recovery';
export default defineEventHandler(async event => { try { const model = await recovery(event), body = await recoveryForm(event); if (body.photos.length !== 1 || body.photos[0]!.id !== body.draft.id) throw new RecoveryFailure('invalid'); await model.photo.execute(body.draft.pet,body.photos[0]!); return { saved:true }; } catch(e) { return recoveryError(event,e); } });
