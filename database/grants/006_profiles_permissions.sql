grant usage on schema public to authenticated;
grant select (id, display_name, city, created_at, updated_at)
on public.profiles to authenticated;
grant update (display_name, city)
on public.profiles to authenticated;

-- No client INSERT/DELETE or UPDATE of identity/server timestamps.
-- Profile deletion follows auth.users deletion; account management is server-side.
