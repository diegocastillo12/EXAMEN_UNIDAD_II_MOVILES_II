import { credentials, credentialError } from '../../../utils/credentials';
export default defineEventHandler(async event => {
  try { await credentials(event).read.resetAccess(); return { allowed: true }; }
  catch (error) { return credentialError(event, error); }
});
