-- HU-14.4 / RF-33. Private, append-only submissions and answers.
create table if not exists public.moderation_appeals (
 id uuid primary key,
 decision_id uuid not null references public.content_moderation_decisions(command_id),
 appellant_id uuid not null references auth.users(id),
 reason text not null check(char_length(public.pet_trim(reason)) between 1 and 1000),
 submitted_at timestamptz not null default clock_timestamp(),
 unique(decision_id,appellant_id)
);
create table if not exists public.moderation_appeal_answers (
 id uuid primary key,
 appeal_id uuid not null unique references public.moderation_appeals(id),
 actor_id uuid not null references auth.users(id),
 reason text not null check(char_length(public.pet_trim(reason)) between 1 and 1000),
 answered_at timestamptz not null default clock_timestamp()
);
create table if not exists public.moderation_appeal_access (
 id bigint generated always as identity primary key,
 actor_id uuid not null references auth.users(id),
 decision_id uuid references public.content_moderation_decisions(command_id),
 accessed_at timestamptz not null default clock_timestamp()
);
create index if not exists moderation_appeals_queue on public.moderation_appeals(submitted_at desc,id desc);
alter table public.moderation_appeals enable row level security;
alter table public.moderation_appeal_answers enable row level security;
alter table public.moderation_appeal_access enable row level security;
