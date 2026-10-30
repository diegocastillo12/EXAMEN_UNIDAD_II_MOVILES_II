revoke all on function public.begin_pet_deletion(uuid,integer),public.finish_pet_deletion(uuid),public.can_write_pet_photo_path(text) from public,anon,authenticated;
grant execute on function public.begin_pet_deletion(uuid,integer),public.finish_pet_deletion(uuid),public.can_write_pet_photo_path(text) to authenticated;
