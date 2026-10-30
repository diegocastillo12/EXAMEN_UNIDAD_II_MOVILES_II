/** Consume only presentation notices; keep integration parameters and fragments. */
export function useRouteNotice() {
  const route = useRoute();
  const router = useRouter();

  return async (reasons: readonly string[]): Promise<string | undefined> => {
    const reason = route.query.reason;
    if (typeof reason !== 'string' || !reasons.includes(reason)) return;
    const { reason: _, ...query } = route.query;
    const failure = await router.replace({ path: route.path, query, hash: route.hash });
    if (!failure) return reason;
  };
}
