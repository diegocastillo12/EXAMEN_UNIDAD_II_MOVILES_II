-- HU-16.1 / RF-35 / #50. Privileged assignment only; no role inheritance.
create table if not exists public.platform_administrators (
 user_id uuid primary key references auth.users(id)
);
alter table public.platform_administrators enable row level security;
revoke all on public.platform_administrators from public,anon,authenticated,service_role;
