-- HU-02.2: a private aggregate per account; no device token or delivery state.
create table if not exists public.alert_preferences (
    owner_id uuid primary key references auth.users(id) on delete cascade,
    enabled boolean not null default false,
    lost_pets boolean not null default true,
    found_pets boolean not null default true,
    case_updates boolean not null default true,
    in_app boolean not null default true,
    push boolean not null default false,
    version integer not null default 1 check (version > 0),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint alert_preferences_enabled_types check (not enabled or lost_pets or found_pets or case_updates),
    constraint alert_preferences_enabled_channels check (not enabled or in_app or push)
);
