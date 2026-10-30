-- Account-scoped completion; clients cannot reset or forge its timestamp.
alter table public.profiles add column if not exists onboarding_completed_at timestamptz;
grant select (onboarding_completed_at) on public.profiles to authenticated;
