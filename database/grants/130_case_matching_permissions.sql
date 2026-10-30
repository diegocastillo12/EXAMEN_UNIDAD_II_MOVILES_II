revoke all on function public.match_case_snapshot(uuid,text,uuid) from public,anon,authenticated,service_role;
revoke all on function public.read_case_match_context(uuid,text,uuid) from public,anon,authenticated,service_role;
revoke all on function public.store_case_match_embedding(uuid,text,uuid,text,uuid,text,real[]) from public,anon,authenticated,service_role;
revoke all on function public.review_case_match(uuid,uuid,text,uuid,text,text,uuid,text,text) from public,anon,authenticated,service_role;
grant execute on function public.read_case_match_context(uuid,text,uuid) to service_role;
grant execute on function public.store_case_match_embedding(uuid,text,uuid,text,uuid,text,real[]) to service_role;
grant execute on function public.review_case_match(uuid,uuid,text,uuid,text,text,uuid,text,text) to service_role;
