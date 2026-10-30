-- HU-08 / RF-08,37. Opaque stable references; no public table access.
create table if not exists public.case_public_links (
 case_source text not null check(case_source in ('lost','found')),
 case_id uuid not null,
 owner_id uuid not null references auth.users(id) on delete cascade,
 public_slug text not null unique default replace(gen_random_uuid()::text,'-','')||replace(gen_random_uuid()::text,'-',''),
 created_at timestamptz not null default clock_timestamp(),
 revoked_at timestamptz,
 primary key(case_source,case_id),
 constraint case_public_slug_shape check(public_slug ~ '^[0-9a-f]{64}$')
);
alter table public.case_public_links enable row level security;
revoke all on table public.case_public_links from public,anon,authenticated;
