revoke all on function public.case_contact_visible(text,uuid) from public,anon,authenticated;
revoke all on function public.read_case_contact(text,uuid) from public,anon,authenticated;
revoke all on function public.set_case_contact(text,uuid,boolean,text,text,boolean,bigint) from public,anon,authenticated;
revoke all on function public.can_read_case_contact_avatar(text) from public,anon,authenticated;
grant execute on function public.read_case_contact(text,uuid),public.set_case_contact(text,uuid,boolean,text,text,boolean,bigint),public.can_read_case_contact_avatar(text) to authenticated;
