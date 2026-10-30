-- HU-01 / RF-01,34: one private profile per Supabase Auth identity.
create table public.profiles (
    id uuid primary key references auth.users (id) on delete cascade,
    display_name text,
    city text,
    created_at timestamptz not null default pg_catalog.now(),
    updated_at timestamptz not null default pg_catalog.now(),
    constraint profiles_display_name_length check (
        display_name is null or pg_catalog.char_length(display_name) between 1 and 120
    ),
    constraint profiles_city_length check (
        city is null or pg_catalog.char_length(city) between 1 and 120
    )
);

alter table public.profiles enable row level security;
revoke all on table public.profiles from public, anon, authenticated;
