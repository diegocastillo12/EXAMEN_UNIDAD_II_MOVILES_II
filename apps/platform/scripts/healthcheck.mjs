// Container liveness only: do not query private cases, log tokens or need curl.
try {
  const response = await fetch(`http://127.0.0.1:${Number(process.env.PORT || 5173)}/health`, {
    signal: AbortSignal.timeout(3000), redirect: 'error',
  });
  if (!response.ok || (await response.json()).status !== 'ok') process.exitCode = 1;
} catch { process.exitCode = 1; }
