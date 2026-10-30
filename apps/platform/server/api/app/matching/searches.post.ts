import { matching, matchingError } from '../../../utils/matching';
export default defineEventHandler(async event=>{
  try {return await (await matching(event,true)).searches.execute();}
  catch(error){return matchingError(event,error);}
});
