-- HU-14.1 / RF-22: private submissions, independent of operational case state.
create table if not exists public.content_reports (
 id uuid primary key,
 reporter_id uuid not null references auth.users(id),
 resource_kind text not null check(resource_kind in ('lost','found','sighting')),
 resource_id uuid not null,
 reason text not null check(char_length(public.pet_trim(reason)) between 1 and 500),
 evidence_note text check(char_length(evidence_note) between 1 and 1000),
 submitted_at timestamptz not null default clock_timestamp()
);
create index if not exists content_reports_reporter_time on public.content_reports(reporter_id,submitted_at desc);
-- Assignment is a privileged server operation, never user metadata or client input.
create table if not exists public.content_report_reviewers (
 user_id uuid primary key references auth.users(id)
);
alter table public.content_reports enable row level security;
alter table public.content_report_reviewers enable row level security;
