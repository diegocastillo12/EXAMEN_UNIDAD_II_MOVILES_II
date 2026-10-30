alter table storage.objects enable row level security;

do $avatar_policies$
begin
    if not exists (select 1 from pg_catalog.pg_policy where polrelid = 'storage.objects'::regclass and polname = 'profile_avatars_account_guard') then
        create policy profile_avatars_account_guard on storage.objects as restrictive for all to authenticated
        using (bucket_id <> 'profile-avatars' or name = (select auth.uid())::text || '/avatar.jpg')
        with check (bucket_id <> 'profile-avatars' or name = (select auth.uid())::text || '/avatar.jpg');
    end if;
    if not exists (select 1 from pg_catalog.pg_policy where polrelid = 'storage.objects'::regclass and polname = 'profile_avatars_anon_guard') then
        create policy profile_avatars_anon_guard on storage.objects as restrictive for all to anon
        using (bucket_id <> 'profile-avatars') with check (bucket_id <> 'profile-avatars');
    end if;
    if not exists (select 1 from pg_catalog.pg_policy where polrelid = 'storage.objects'::regclass and polname = 'profile_avatars_select_own') then
        create policy profile_avatars_select_own on storage.objects for select to authenticated
        using (bucket_id = 'profile-avatars' and name = (select auth.uid())::text || '/avatar.jpg');
    end if;
    if not exists (select 1 from pg_catalog.pg_policy where polrelid = 'storage.objects'::regclass and polname = 'profile_avatars_insert_own') then
        create policy profile_avatars_insert_own on storage.objects for insert to authenticated
        with check (bucket_id = 'profile-avatars' and name = (select auth.uid())::text || '/avatar.jpg');
    end if;
    if not exists (select 1 from pg_catalog.pg_policy where polrelid = 'storage.objects'::regclass and polname = 'profile_avatars_update_own') then
        create policy profile_avatars_update_own on storage.objects for update to authenticated
        using (bucket_id = 'profile-avatars' and name = (select auth.uid())::text || '/avatar.jpg')
        with check (bucket_id = 'profile-avatars' and name = (select auth.uid())::text || '/avatar.jpg');
    end if;
end;
$avatar_policies$;
