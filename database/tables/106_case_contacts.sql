-- Explicit per-case consent; private table, public projection through RPC only.
create table if not exists public.case_contacts (
 case_source text not null check(case_source in ('lost','found')),
 case_id uuid not null,
 owner_id uuid not null references auth.users(id) on delete cascade,
 enabled boolean not null default false,
 display_name text not null default '',
 phone text not null default '',
 share_photo boolean not null default false,
 version bigint not null default 1 check(version>0),
 updated_at timestamptz not null default now(),
 primary key(case_source,case_id),
 check(not enabled or (char_length(display_name) between 2 and 80 and display_name !~ '[[:cntrl:]]' and phone ~ '^\+[1-9][0-9]{7,14}$')),
 check(enabled or (display_name='' and phone='' and not share_photo))
);
create index if not exists case_contacts_shared_avatar on public.case_contacts(owner_id) where enabled and share_photo;
alter table public.case_contacts enable row level security;
revoke all on public.case_contacts from public,anon,authenticated;
