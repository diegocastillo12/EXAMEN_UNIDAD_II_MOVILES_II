-- Runs only through the auth.users trigger. Metadata is display data, not a role.
create function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.profiles (id, display_name)
    values (
        new.id,
        nullif(pg_catalog.left(pg_catalog.btrim(
            coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name', '')
        ), 120), '')
    )
    on conflict (id) do nothing;
    return new;
end;
$$;

revoke all on function public.handle_new_auth_user() from public, anon, authenticated;
