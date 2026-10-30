revoke all on function public.authorized_timeline_case(text,uuid) from public,anon,authenticated,service_role;
revoke all on function public.can_read_case_timeline(text,uuid) from public,anon,service_role;
revoke all on function public.read_case_timeline(text,uuid,timestamptz,text,integer) from public,anon,service_role;
revoke all on function public.read_sighting_review(uuid,integer) from public,anon,service_role;
revoke all on function public.read_sighting_evidence(uuid) from public,anon,service_role;
revoke all on function public.review_sighting(uuid,uuid,integer,text,text) from public,anon,service_role;
grant execute on function public.can_read_case_timeline(text,uuid),public.read_case_timeline(text,uuid,timestamptz,text,integer),
 public.read_sighting_review(uuid,integer),public.read_sighting_evidence(uuid),public.review_sighting(uuid,uuid,integer,text,text) to authenticated;
