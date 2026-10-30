-- HU-11 / RF-12,14 / #38,#39. Append-only decisions, never evidence replacement.
create table if not exists public.sighting_reviews (
 command_id uuid primary key,
 sighting_id uuid not null references public.public_sightings(id),
 revision integer not null check(revision>0),
 previous_state text not null check(previous_state in ('unreviewed','useful','doubtful','rejected','confirmed')),
 state text not null check(state in ('useful','doubtful','rejected','confirmed')),
 reason text not null check(char_length(public.pet_trim(reason)) between 1 and 500),
 actor_id uuid not null references auth.users(id),
 reviewed_at timestamptz not null default clock_timestamp(),
 unique(sighting_id,revision),
 check(previous_state<>state)
);
alter table public.sighting_reviews enable row level security;
revoke all on table public.sighting_reviews from public,anon,authenticated,service_role;
create index if not exists public_sightings_observed_order on public.public_sightings(case_source,case_id,observed_at desc,id desc);
