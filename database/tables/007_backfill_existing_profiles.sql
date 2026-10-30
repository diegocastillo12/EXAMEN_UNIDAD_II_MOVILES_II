-- Covers users created before this migration, including existing Google accounts.
insert into public.profiles (id, display_name)
select
    users.id,
    nullif(pg_catalog.left(pg_catalog.btrim(
        coalesce(users.raw_user_meta_data ->> 'full_name', users.raw_user_meta_data ->> 'name', '')
    ), 120), '')
from auth.users as users
on conflict (id) do nothing;
