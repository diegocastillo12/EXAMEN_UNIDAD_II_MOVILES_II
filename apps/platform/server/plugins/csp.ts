export default defineNitroPlugin(nitro => {
  nitro.hooks.hook('render:html', (html, { event }) => {
    const nonce = event.context.cspNonce;
    if (typeof nonce !== 'string') return;
    for (const key of ['head', 'bodyPrepend', 'body', 'bodyAppend'] as const) {
      html[key] = html[key].map(fragment => fragment.replace(/<(script|style)(?=[\s>])/g, `<$1 nonce="${nonce}"`));
    }
  });
});
