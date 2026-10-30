begin;
-- A permissive policy belonging to another bucket must not expose avatars.
create policy avatar_test_other_policy on storage.objects for select to anon, authenticated using (true);
do $$
begin
    if not exists (select 1 from storage.buckets where id = 'profile-avatars'
        and public = false and file_size_limit = 2097152 and allowed_mime_types = array['image/jpeg'])
    then raise exception 'Avatar bucket privacy/limits are incorrect'; end if;
end;
$$;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"44444444-4444-4444-8444-444444444444","role":"authenticated"}', true);
insert into storage.objects (id, bucket_id, name)
values ('66666666-6666-4666-8666-666666666666', 'profile-avatars', '44444444-4444-4444-8444-444444444444/avatar.jpg');
update storage.objects set name = name where id = '66666666-6666-4666-8666-666666666666';
do $$
begin
    begin
        insert into storage.objects (id, bucket_id, name)
        values ('88888888-8888-4888-8888-888888888888', 'profile-avatars', '55555555-5555-4555-8555-555555555555/avatar.jpg');
        raise exception 'Avatar of another account was writable';
    exception when insufficient_privilege then null;
    end;
    begin
        update storage.objects set name = '44444444-4444-4444-8444-444444444444/other.jpg' where id = '66666666-6666-4666-8666-666666666666';
        raise exception 'Client changed stable avatar path';
    exception when insufficient_privilege then null;
    end;
end;
$$;
select set_config('request.jwt.claims', '{"sub":"55555555-5555-4555-8555-555555555555","role":"authenticated"}', true);
do $$
declare changed integer;
begin
    if exists (select 1 from storage.objects where id = '66666666-6666-4666-8666-666666666666') then raise exception 'Cross-account avatar read'; end if;
    update storage.objects set name = name where id = '66666666-6666-4666-8666-666666666666';
    get diagnostics changed = row_count;
    if changed <> 0 then raise exception 'Cross-account avatar update'; end if;
end;
$$;
insert into storage.objects (id, bucket_id, name)
values ('77777777-7777-4777-8777-777777777777', 'profile-avatars', '55555555-5555-4555-8555-555555555555/avatar.jpg');
reset role;
set local role anon;
do $$
begin
    if exists (select 1 from storage.objects where bucket_id = 'profile-avatars')
    then raise exception 'Anonymous avatar access'; end if;
end;
$$;
reset role;
rollback;

