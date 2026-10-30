drop policy if exists lost_cases_owner_read on public.lost_cases;
create policy lost_cases_owner_read on public.lost_cases for select to authenticated using(owner_id=auth.uid());
drop policy if exists lost_cases_owner_guard on public.lost_cases;
create policy lost_cases_owner_guard on public.lost_cases as restrictive for all to authenticated using(owner_id=auth.uid()) with check(false);
drop policy if exists lost_cases_anon_guard on public.lost_cases;
create policy lost_cases_anon_guard on public.lost_cases as restrictive for all to anon using(false) with check(false);
drop policy if exists case_events_client_guard on public.case_events;
create policy case_events_client_guard on public.case_events as restrictive for all to anon,authenticated using(false) with check(false);
-- Buckets stay private. Grant only selected verified derivatives in active cases.
drop policy if exists pet_renditions_read_guard on storage.objects;
create policy pet_renditions_read_guard on storage.objects as restrictive for select to authenticated
using(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails') or public.owns_pet_photo_rendition(name,true) or public.is_public_case_rendition(name));
drop policy if exists pet_renditions_anon_guard on storage.objects;
create policy pet_renditions_anon_guard on storage.objects as restrictive for select to anon
using(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails') or public.is_public_case_rendition(name));
drop policy if exists pet_renditions_anon_insert_guard on storage.objects;
create policy pet_renditions_anon_insert_guard on storage.objects as restrictive for insert to anon
with check(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails'));
drop policy if exists pet_renditions_anon_update_guard on storage.objects;
create policy pet_renditions_anon_update_guard on storage.objects as restrictive for update to anon
using(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails'))
with check(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails'));
-- Anonymous DELETE must remain impossible even if a future permissive policy grants it.
drop policy if exists pet_renditions_anon_delete_guard on storage.objects;
create policy pet_renditions_anon_delete_guard on storage.objects as restrictive for delete to anon
using(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails'));
drop policy if exists pet_renditions_case_read on storage.objects;
create policy pet_renditions_case_read on storage.objects for select to anon,authenticated
using(bucket_id in ('pet-photo-renditions','pet-photo-thumbnails') and public.is_public_case_rendition(name));
