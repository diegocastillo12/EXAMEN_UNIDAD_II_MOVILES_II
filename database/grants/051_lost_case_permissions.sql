revoke all on public.lost_cases,public.case_events from public,anon,authenticated;
grant select on public.lost_cases to authenticated;
revoke all on function public.publish_lost_case(uuid,uuid,integer,timestamptz,double precision,double precision,text,uuid[]) from public,anon,authenticated;
grant execute on function public.publish_lost_case(uuid,uuid,integer,timestamptz,double precision,double precision,text,uuid[]) to authenticated;
revoke all on function public.read_public_lost_case(uuid),public.is_public_case_rendition(text) from public,anon,authenticated;
grant execute on function public.read_public_lost_case(uuid),public.is_public_case_rendition(text) to anon,authenticated;
