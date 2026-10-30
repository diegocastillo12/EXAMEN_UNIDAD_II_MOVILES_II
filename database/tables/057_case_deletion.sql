-- Retain stable publication IDs and history while removing public/list visibility.
alter table public.lost_cases add column if not exists deleted_at timestamptz;
alter table public.found_cases add column if not exists deleted_at timestamptz;
