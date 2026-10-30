-- Execute against a DEVELOPMENT Supabase database after the auth_profiles migration.
-- Native assertions: no pgTAP dependency. Test users/data are rolled back.
begin;

insert into auth.users (id, aud, role, email, raw_user_meta_data)
values
    ('11111111-1111-4111-8111-111111111111', 'authenticated', 'authenticated', 'owner-one@profiles-test.invalid', '{"full_name":"Owner One"}'),
    ('22222222-2222-4222-8222-222222222222', 'authenticated', 'authenticated', 'owner-two@profiles-test.invalid', '{"name":"Owner Two"}');

do $$
begin
    if (select count(*) from public.profiles where id in (
        '11111111-1111-4111-8111-111111111111', '22222222-2222-4222-8222-222222222222'
    )) <> 2 then raise exception 'Auth trigger did not create both profiles'; end if;
    if (select display_name from public.profiles where id = '11111111-1111-4111-8111-111111111111') <> 'Owner One'
    then raise exception 'Profile metadata projection failed'; end if;
    if has_function_privilege('authenticated', 'public.handle_new_auth_user()', 'execute')
    then raise exception 'Client can execute the privileged trigger function'; end if;
end;
$$;

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}', true);

do $$
declare changed integer;
begin
    if (select count(*) from public.profiles) <> 1 then raise exception 'Cross-user profile read allowed'; end if;
    update public.profiles set display_name = 'Updated owner' where id = '11111111-1111-4111-8111-111111111111';
    get diagnostics changed = row_count;
    if changed <> 1 then raise exception 'Owner update was rejected'; end if;
    update public.profiles set display_name = 'Unauthorized' where id = '22222222-2222-4222-8222-222222222222';
    get diagnostics changed = row_count;
    if changed <> 0 then raise exception 'Cross-user profile update allowed'; end if;
    begin
        update public.profiles set created_at = '2000-01-01' where id = '11111111-1111-4111-8111-111111111111';
        raise exception 'Client changed a server timestamp';
    exception when insufficient_privilege then null;
    end;
    begin
        delete from public.profiles where id = '11111111-1111-4111-8111-111111111111';
        raise exception 'Client deleted a profile';
    exception when insufficient_privilege then null;
    end;
end;
$$;

reset role;
set local role anon;
do $$
begin
    begin
        perform id from public.profiles;
        raise exception 'Anonymous profile read allowed';
    exception when insufficient_privilege then null;
    end;
end;
$$;
reset role;
rollback;
