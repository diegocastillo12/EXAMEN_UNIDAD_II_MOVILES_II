import { ReaderFailure } from '../../../shared/features/case_reader/domain/case';
export default defineEventHandler(async event => {
  const abort = new AbortController();
  event.node.res.once('close', () => { if (!event.node.res.writableEnded) abort.abort(); });
  try {
    const value = await caseReader().read.execute(getRouterParam(event, 'slug'), abort.signal);
    if (value.state === 'unavailable') setResponseStatus(event, 404);
    return value;
  } catch (error) {
    setResponseStatus(event, error instanceof ReaderFailure && error.kind === 'not_found' ? 404 : 503);
    return { error: 'unavailable' };
  }
});
