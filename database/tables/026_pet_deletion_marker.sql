alter table public.pets add column if not exists deletion_requested_at timestamptz;
create table if not exists public.pet_deletions (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  deleted_at timestamptz not null default now()
);
alter table public.pet_deletions enable row level security;
revoke all on public.pet_deletions from public,anon,authenticated;
