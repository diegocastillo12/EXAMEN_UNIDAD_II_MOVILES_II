import { matching, matchingBody, matchingError } from '../../utils/matching';
export default defineEventHandler(async event=>{
  try {const model=await matching(event);await model.review.execute(await matchingBody(event));return {saved:true};}
  catch(error){return matchingError(event,error);}
});
