revoke all on function public.read_case_closure(text,uuid),public.close_recovery_case(uuid,text,uuid,text,text) from public,anon,authenticated,service_role;
grant execute on function public.read_case_closure(text,uuid),public.close_recovery_case(uuid,text,uuid,text,text) to authenticated;
