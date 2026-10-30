import { account, accountError } from '../../utils/account';
export default defineEventHandler(async event => {
  try { return { canReviewReports: await account(event, true).management.execute() }; }
  catch (error) { return accountError(event, error); }
});

