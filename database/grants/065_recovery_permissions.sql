-- All modifications remain RPC-only; clients cannot forge links by updating rows.
revoke execute on function public.publish_found_case(uuid,timestamptz,double precision,double precision,text,text,text,text,text,text,text,uuid[]) from public,anon,authenticated;
revoke all on function public.publish_recovery_report(uuid,text,uuid,boolean,timestamptz,double precision,double precision,text,text,text,text,text,text,text,uuid[]),
 public.list_open_recovery_searches(),public.resolve_recovery_search(uuid,boolean),public.list_my_recovery_reports() from public,anon,authenticated;
grant execute on function public.publish_recovery_report(uuid,text,uuid,boolean,timestamptz,double precision,double precision,text,text,text,text,text,text,text,uuid[]),
 public.list_open_recovery_searches(),public.resolve_recovery_search(uuid,boolean),public.list_my_recovery_reports() to authenticated;
revoke all on function public.read_recovery_pet_case(uuid),public.read_recovery_report(uuid),public.list_recovery_observations(uuid,boolean) from public,anon,authenticated;
grant execute on function public.read_recovery_pet_case(uuid),public.read_recovery_report(uuid),public.list_recovery_observations(uuid,boolean) to anon,authenticated;

revoke all on function public.prepare_recovery_report(uuid,uuid[],text,uuid,boolean) from public,anon,authenticated;
grant execute on function public.prepare_recovery_report(uuid,uuid[],text,uuid,boolean) to authenticated;
