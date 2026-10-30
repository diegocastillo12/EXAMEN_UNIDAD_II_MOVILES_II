revoke all on public.pet_photo_deletions from public,anon,authenticated;
revoke all on public.pet_photos from public,anon,authenticated;
grant select(id,pet_id,owner_id,status,created_at,is_primary,processed_at) on public.pet_photos to authenticated;
revoke all on function public.reserve_pet_photo(uuid,uuid),public.publish_pet_photo(uuid) from public,anon,authenticated;
revoke all on function public.prepare_pet_photo(uuid,uuid,uuid,text),public.complete_pet_photo_processing(uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.prepare_pet_photo(uuid,uuid,uuid,text),public.complete_pet_photo_processing(uuid,uuid,text) to service_role;
revoke all on function public.list_pet_photos(uuid),public.set_primary_pet_photo(uuid,uuid,integer),public.begin_pet_photo_removal(uuid,uuid),public.owns_pet_photo_rendition(text,boolean) from public,anon,authenticated;
grant execute on function public.list_pet_photos(uuid),public.set_primary_pet_photo(uuid,uuid,integer),public.begin_pet_photo_removal(uuid,uuid),public.owns_pet_photo_rendition(text,boolean) to authenticated;
