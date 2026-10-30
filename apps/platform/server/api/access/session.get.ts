import { account, accountCookie, accountError } from '../../utils/account';
import { AccessFailure } from '../../../shared/features/access/domain/access';
export default defineEventHandler(async event => {
  try {
    if (!getCookie(event, accountCookie)) throw new AccessFailure('unauthenticated');
    return await account(event).access.session();
  } catch (error) { return accountError(event, error); }
});

