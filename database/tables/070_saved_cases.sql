-- User-requested extension of HU-07 / RF-13: private saved-case markers.
create table if not exists public.saved_cases (
 owner_id uuid not null references auth.users(id) on delete cascade,
 case_source text not null check (case_source in ('lost','found')),
 case_id uuid not null,
 saved boolean not null,
 version integer not null default 1 check (version > 0),
 updated_at timestamptz not null default now(),
 primary key (owner_id,case_source,case_id)
);
alter table public.saved_cases enable row level security;
