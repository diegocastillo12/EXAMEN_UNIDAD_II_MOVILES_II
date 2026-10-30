import { startAccountOAuth } from '../../../utils/account_oauth';
// Retained endpoint; authentication now establishes a general account session.
export default defineEventHandler(startAccountOAuth);
