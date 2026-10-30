revoke all on table public.saved_cases from public,anon,authenticated;
grant select(owner_id,case_source,case_id,saved,version) on public.saved_cases to authenticated;
revoke all on function public.read_saved_case(text,uuid) from public,anon,authenticated;
revoke all on function public.set_saved_case(text,uuid,boolean,integer) from public,anon,authenticated;
grant execute on function public.read_saved_case(text,uuid) to authenticated;
grant execute on function public.set_saved_case(text,uuid,boolean,integer) to authenticated;
