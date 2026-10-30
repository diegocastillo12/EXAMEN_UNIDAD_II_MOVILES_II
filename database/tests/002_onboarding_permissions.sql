begin;
insert into auth.users (id, aud, role, email, raw_user_meta_data) values
('33333333-3333-4333-8333-333333333333', 'authenticated', 'authenticated', 'onboarding-one@tests.invalid', '{}'),
('44444444-4444-4444-8444-444444444444', 'authenticated', 'authenticated', 'onboarding-two@tests.invalid', '{}');
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"33333333-3333-4333-8333-333333333333","role":"authenticated"}', true);
select public.complete_onboarding();
do $$
declare saved_time timestamptz;
begin
    if (select onboarding_completed_at from public.profiles) is null then
        raise exception 'Completion was not saved';
    end if;
    select onboarding_completed_at into saved_time from public.profiles;
    perform public.complete_onboarding();
    if (select onboarding_completed_at from public.profiles) <> saved_time then
        raise exception 'Repeated completion changed the timestamp';
    end if;
    begin
        update public.profiles set onboarding_completed_at = null;
        raise exception 'Client reset completion timestamp';
    exception when insufficient_privilege then null;
    end;
end;
$$;
reset role;
do $$
begin
    if (select onboarding_completed_at from public.profiles where id = '44444444-4444-4444-8444-444444444444') is not null then
        raise exception 'Another account was marked complete';
    end if;
    if has_function_privilege('anon', 'public.complete_onboarding()', 'execute') then
        raise exception 'Anonymous clients can complete onboarding';
    end if;
end;
$$;
rollback;
