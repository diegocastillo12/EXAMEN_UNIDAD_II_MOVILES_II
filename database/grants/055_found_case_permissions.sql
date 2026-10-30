revoke all on public.found_cases,public.found_case_photos,public.found_case_events from public,anon,authenticated;
revoke all on function public.list_found_photo_cleanup(uuid) from public,anon,authenticated;
grant execute on function public.list_found_photo_cleanup(uuid) to authenticated;
revoke all on function public.list_my_found_cases() from public,anon,authenticated;
grant execute on function public.list_my_found_cases() to authenticated;
grant select(id,owner_id,status,species,created_at) on public.found_cases to authenticated;
revoke all on function public.prepare_found_case(uuid,uuid[]),public.publish_found_case(uuid,timestamptz,double precision,double precision,text,text,text,text,text,text,text,uuid[]),
    public.begin_found_case_discard(uuid),public.finish_found_case_discard(uuid) from public,anon,authenticated;
grant execute on function public.prepare_found_case(uuid,uuid[]),public.publish_found_case(uuid,timestamptz,double precision,double precision,text,text,text,text,text,text,text,uuid[]),
    public.begin_found_case_discard(uuid),public.finish_found_case_discard(uuid) to authenticated;
revoke all on function public.prepare_found_case_photo(uuid,uuid,uuid,text),public.complete_found_case_photo(uuid,uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.prepare_found_case_photo(uuid,uuid,uuid,text),public.complete_found_case_photo(uuid,uuid,uuid,text) to service_role;
revoke all on function public.read_public_found_case(uuid),public.can_read_found_photo(text),public.can_delete_found_photo(text) from public,anon,authenticated;
grant execute on function public.read_public_found_case(uuid),public.can_read_found_photo(text),public.can_delete_found_photo(text) to anon,authenticated;
