revoke all on function public.lock_user_pair(uuid,uuid),public.users_have_block(uuid,uuid),public.user_block_json(public.user_blocks) from public,anon,authenticated,service_role;
revoke all on function public.prepare_user_block(text,uuid),public.list_user_blocks(uuid),public.set_user_block(uuid,boolean,bigint) from public,anon,service_role;
grant execute on function public.prepare_user_block(text,uuid),public.list_user_blocks(uuid),public.set_user_block(uuid,boolean,bigint) to authenticated;
