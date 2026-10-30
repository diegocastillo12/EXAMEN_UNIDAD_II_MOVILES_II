create or replace function public.complete_onboarding()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare actor uuid := auth.uid();
begin
    if actor is null then
        raise exception 'Authentication required' using errcode = '42501';
    end if;
    update public.profiles
    set onboarding_completed_at = pg_catalog.now()
    where id = actor and onboarding_completed_at is null;
    if not found and not exists (select 1 from public.profiles where id = actor) then
        raise exception 'Profile unavailable' using errcode = 'P0002';
    end if;
end;
$$;
revoke all on function public.complete_onboarding() from public, anon, authenticated;
grant execute on function public.complete_onboarding() to authenticated;
