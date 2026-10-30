-- HU-01.7 / RF-01: editable profile values, server fields and safe retries.
-- Development only; all fixtures are rolled back.
begin;
insert into auth.users (id, aud, role, email, raw_user_meta_data)
values ('33333333-3333-4333-8333-333333333333', 'authenticated', 'authenticated', 'profile-edit@tests.invalid', '{}');
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"33333333-3333-4333-8333-333333333333","role":"authenticated"}', true);
do $$
begin
    if has_column_privilege('authenticated', 'public.profiles', 'id', 'update')
        or has_column_privilege('authenticated', 'public.profiles', 'created_at', 'update')
        or has_column_privilege('authenticated', 'public.profiles', 'updated_at', 'update')
        or has_column_privilege('authenticated', 'public.profiles', 'onboarding_completed_at', 'update')
    then raise exception 'Server-managed columns are writable'; end if;
    begin
        update public.profiles set id = '44444444-4444-4444-8444-444444444444';
        raise exception 'Client changed profile identity';
    exception when insufficient_privilege then null;
    end;
    begin
        update public.profiles set updated_at = '2000-01-01';
        raise exception 'Client changed update timestamp';
    exception when insufficient_privilege then null;
    end;
    begin
        update public.profiles set display_name = repeat('x', 121);
        raise exception 'Overlong name accepted';
    exception when check_violation then null;
    end;
    begin
        update public.profiles set city = '';
        raise exception 'Empty city string accepted';
    exception when check_violation then null;
    end;
    update public.profiles set display_name = repeat('🐾', 120), city = 'Cusco';
    update public.profiles set display_name = repeat('🐾', 120), city = 'Cusco';
    if (select count(*) from public.profiles) <> 1 then raise exception 'Retry duplicated profile'; end if;
    if (select char_length(display_name) from public.profiles) <> 120 then raise exception 'Unicode limit differs'; end if;
    update public.profiles set display_name = null, city = null;
    if exists (select 1 from public.profiles where display_name is not null or city is not null)
    then raise exception 'Optional values cannot be cleared'; end if;
    update public.profiles set display_name = 'Updated profile', city = 'Lima';
end;
$$;
reset role;
do $$
begin
    if not exists (select 1 from public.profiles
        where id = '33333333-3333-4333-8333-333333333333'
        and display_name = 'Updated profile' and city = 'Lima')
    then raise exception 'Edited values were not persisted'; end if;
end;
$$;
rollback;
