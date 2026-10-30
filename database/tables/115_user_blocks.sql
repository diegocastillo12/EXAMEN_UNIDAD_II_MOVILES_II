-- HU-14.2 / RF-23. Private, directional choices; an active choice stops
-- the agreed interactions in both directions. No public account directory.
create table if not exists public.user_blocks (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 blocked_id uuid not null references auth.users(id) on delete cascade,
 label text not null check (char_length(label) between 1 and 120),
 enabled boolean not null default false,
 version bigint not null default 0 check(version between 0 and 2147483647),
 updated_at timestamptz not null default clock_timestamp(),
 unique(owner_id,blocked_id),
 check(owner_id<>blocked_id)
);
alter table public.user_blocks enable row level security;
revoke all on table public.user_blocks from public,anon,authenticated,service_role;
