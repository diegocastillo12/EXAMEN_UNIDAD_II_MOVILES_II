-- HU-05 / RF-05. Private source, explicit public projection via RPC only.
create table if not exists public.lost_cases (
    id uuid primary key,
    owner_id uuid not null references auth.users(id),
    pet_id uuid not null references public.pets(id),
    pet_version integer not null,
    status text not null default 'active' check(status in ('active','resolved')),
    occurred_at timestamptz not null,
    latitude double precision not null check(latitude between -85 and 85),
    longitude double precision not null check(longitude between -180 and 180),
    place_reference text not null check(char_length(place_reference) between 1 and 120),
    public_latitude double precision not null,
    public_longitude double precision not null,
    pet_name text not null,
    species text not null,
    species_detail text,
    size text not null,
    sex text,
    age_months integer not null,
    traits text not null,
    photo_ids uuid[] not null check(cardinality(photo_ids) between 1 and 3),
    created_at timestamptz not null default clock_timestamp()
);
create unique index if not exists lost_cases_one_active_pet on public.lost_cases(pet_id) where status='active';
create index if not exists lost_cases_owner_created on public.lost_cases(owner_id,created_at desc,id);
create table if not exists public.case_events (
    id bigint generated always as identity primary key,
    case_id uuid not null references public.lost_cases(id),
    actor_id uuid not null references auth.users(id),
    event_type text not null check(event_type in ('published','resolved')),
    created_at timestamptz not null default clock_timestamp(),
    unique(case_id,event_type)
);
alter table public.lost_cases enable row level security;
alter table public.case_events enable row level security;
