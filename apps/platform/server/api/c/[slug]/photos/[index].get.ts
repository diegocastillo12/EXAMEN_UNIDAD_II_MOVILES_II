export default defineEventHandler(async event => {
  const abort = new AbortController();
  event.node.res.once('close', () => { if (!event.node.res.writableEnded) abort.abort(); });
  try {
    const bytes = await caseReader().photo.execute(getRouterParam(event, 'slug'), Number(getRouterParam(event, 'index')), abort.signal);
    setHeader(event, 'Content-Type', 'image/jpeg');
    return Buffer.from(bytes);
  } catch (error) {
    setResponseStatus(event, error instanceof Error && 'kind' in error && error.kind === 'not_found' ? 404 : 503);
    return { error: 'unavailable' };
  }
});
