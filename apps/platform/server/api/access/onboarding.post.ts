import { account, accountError } from '../../utils/account';
export default defineEventHandler(async event => {
  try { return await account(event, true).onboarding.execute(); }
  catch (error) { return accountError(event, error); }
});

