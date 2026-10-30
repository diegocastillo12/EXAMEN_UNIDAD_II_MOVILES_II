-- HU-14.3 / RF-22,33. Operational lifecycle remains independent.
create table if not exists public.content_visibility (
 resource_kind text not null check(resource_kind in ('lost','found','sighting')),
 resource_id uuid not null,
 hidden boolean not null,
 version integer not null check(version>0),
 primary key(resource_kind,resource_id)
);
create table if not exists public.content_report_resolutions (
 report_id uuid primary key references public.content_reports(id),
 version integer not null check(version>0),
 resolved_at timestamptz not null default clock_timestamp()
);
create table if not exists public.content_moderation_decisions (
 command_id uuid primary key,
 report_id uuid not null references public.content_reports(id),
 actor_id uuid not null references auth.users(id),
 action text not null check(action in ('hide','show','dismiss')),
 reason text not null check(char_length(public.pet_trim(reason)) between 1 and 500),
 report_version integer not null,
 resource_version integer not null,
 hidden boolean not null,
 decided_at timestamptz not null default clock_timestamp(),
 unique(report_id,report_version)
);
create table if not exists public.content_moderation_access (
 id bigint generated always as identity primary key,
 actor_id uuid not null references auth.users(id),
 report_id uuid references public.content_reports(id),
 action text not null check(action in ('queue','detail','evidence','decision')),
 accessed_at timestamptz not null default clock_timestamp()
);
create index if not exists moderation_queue_order on public.content_reports(submitted_at desc,id desc);
alter table public.content_visibility enable row level security;
alter table public.content_report_resolutions enable row level security;
alter table public.content_moderation_decisions enable row level security;
alter table public.content_moderation_access enable row level security;
