import { credentials, credentialError } from '../../../utils/credentials';
export default defineEventHandler(async event => {
  try { const service = credentials(event); return { progress: await service.read.execute() }; }
  catch (error) { return credentialError(event, error); }
});
