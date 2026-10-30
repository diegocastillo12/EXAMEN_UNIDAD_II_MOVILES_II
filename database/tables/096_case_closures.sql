-- HU-13 / RF-07. Private, immutable receipt; no invented history for old closures.
create table if not exists public.case_closures (
 command_id uuid primary key,
 case_source text not null check(case_source in ('lost','found')),
 case_id uuid not null,
 actor_id uuid not null references auth.users(id),
 closed_at timestamptz not null default clock_timestamp(),
 reason text not null check(char_length(reason) between 1 and 500),
 evidence_note text check(char_length(evidence_note) between 1 and 500),
 unique(case_source,case_id)
);
alter table public.case_closures enable row level security;
revoke all on public.case_closures from public,anon,authenticated,service_role;
