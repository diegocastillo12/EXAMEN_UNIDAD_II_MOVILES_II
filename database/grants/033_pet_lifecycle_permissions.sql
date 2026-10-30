revoke all on function public.archive_pet(uuid,integer),public.restore_pet(uuid,integer),public.begin_pet_deletion(uuid,integer),public.finish_pet_deletion(uuid),public.protect_pet_case_history() from public,anon,authenticated;
grant execute on function public.archive_pet(uuid,integer),public.restore_pet(uuid,integer),public.begin_pet_deletion(uuid,integer),public.finish_pet_deletion(uuid) to authenticated;
-- Preserve SELECT + owner RLS. No direct writes to lifecycle/case guards.
revoke insert,update,delete on public.pets from anon,authenticated;
