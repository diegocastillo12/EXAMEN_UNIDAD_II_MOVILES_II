revoke all on function public.list_saved_cases(jsonb,integer) from public,anon,authenticated;
grant execute on function public.list_saved_cases(jsonb,integer) to authenticated;
