-- Authenticated readers may sign only avatars explicitly shared on visible cases.
-- Split the old ALL guard: sharing may widen SELECT, never writes.
drop policy if exists profile_avatars_account_guard on storage.objects;
drop policy if exists profile_avatars_select_guard on storage.objects;
create policy profile_avatars_select_guard on storage.objects as restrictive for select to authenticated
using(bucket_id<>'profile-avatars' or name=auth.uid()::text||'/avatar.jpg' or public.can_read_case_contact_avatar(name));
drop policy if exists profile_avatars_insert_guard on storage.objects;
create policy profile_avatars_insert_guard on storage.objects as restrictive for insert to authenticated
with check(bucket_id<>'profile-avatars' or name=auth.uid()::text||'/avatar.jpg');
drop policy if exists profile_avatars_update_guard on storage.objects;
create policy profile_avatars_update_guard on storage.objects as restrictive for update to authenticated
using(bucket_id<>'profile-avatars' or name=auth.uid()::text||'/avatar.jpg')
with check(bucket_id<>'profile-avatars' or name=auth.uid()::text||'/avatar.jpg');
drop policy if exists profile_avatars_delete_guard on storage.objects;
create policy profile_avatars_delete_guard on storage.objects as restrictive for delete to authenticated
using(bucket_id<>'profile-avatars' or name=auth.uid()::text||'/avatar.jpg');
drop policy if exists case_contact_avatar_read on storage.objects;
create policy case_contact_avatar_read on storage.objects for select to authenticated
using(bucket_id='profile-avatars' and public.can_read_case_contact_avatar(name));
