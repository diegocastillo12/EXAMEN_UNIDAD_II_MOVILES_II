import { matching, matchingBody, matchingError } from '../../utils/matching';
export default defineEventHandler(async event=>{
  try {const model=await matching(event);return await model.find.execute(await matchingBody(event));}
  catch(error){return matchingError(event,error);}
});
