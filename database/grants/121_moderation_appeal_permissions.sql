revoke all on public.moderation_appeals,public.moderation_appeal_answers,public.moderation_appeal_access from public,anon,authenticated,service_role;
revoke all on sequence public.moderation_appeal_access_id_seq from public,anon,authenticated,service_role;
revoke all on function public.owns_moderated_resource(text,uuid,uuid),public.read_moderation_appeal(uuid),public.list_moderation_appeals(boolean,timestamptz,uuid),public.submit_moderation_appeal(uuid,uuid,text),public.answer_moderation_appeal(uuid,uuid,text) from public,anon,authenticated,service_role;
grant execute on function public.read_moderation_appeal(uuid),public.list_moderation_appeals(boolean,timestamptz,uuid),public.submit_moderation_appeal(uuid,uuid,text),public.answer_moderation_appeal(uuid,uuid,text) to authenticated;
