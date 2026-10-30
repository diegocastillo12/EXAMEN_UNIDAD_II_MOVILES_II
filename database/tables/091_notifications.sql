-- HU-12 / RF-16,17,18. Private subscriptions, inbox and durable delivery outbox.
create table if not exists public.alert_subscriptions (
 owner_id uuid not null references auth.users(id) on delete cascade,
 target_kind text not null check(target_kind in ('lost','found','zone')),
 target_id uuid not null, following boolean not null, version integer not null check(version>0),
 primary key(owner_id,target_kind,target_id)
);
create table if not exists public.alert_subscription_commands (
 id uuid primary key, owner_id uuid not null references auth.users(id) on delete cascade,
 target_kind text not null, target_id uuid not null, following boolean not null,
 expected_version integer not null, receipt jsonb not null
);
create table if not exists public.notifications (
 id bigint generated always as identity primary key,
 owner_id uuid not null references auth.users(id) on delete cascade,
 event_key text not null, case_source text not null check(case_source in ('lost','found')),
 case_id uuid not null, kind text not null check(kind in ('published','update','resolved')),
 title text not null, created_at timestamptz not null default clock_timestamp(), read_at timestamptz,
 unique(owner_id,event_key)
);
create index if not exists notifications_owner_page on public.notifications(owner_id,id desc);
create table if not exists public.push_devices (
 token text primary key check(length(token) between 20 and 4096),
 owner_id uuid not null references auth.users(id) on delete cascade,
 updated_at timestamptz not null default clock_timestamp(), disabled_at timestamptz
);
create table if not exists public.notification_deliveries (
 notification_id bigint primary key references public.notifications(id) on delete cascade,
 attempts integer not null default 0, next_attempt_at timestamptz not null default clock_timestamp(),
 lease uuid, leased_until timestamptz, status text not null default 'pending'
 check(status in ('pending','sent','cancelled')), last_error text, sent_at timestamptz
);
create index if not exists notification_delivery_due on public.notification_deliveries(next_attempt_at) where status='pending';
alter table public.alert_subscriptions enable row level security;
alter table public.alert_subscription_commands enable row level security;
alter table public.notifications enable row level security;
alter table public.push_devices enable row level security;
alter table public.notification_deliveries enable row level security;
revoke all on public.alert_subscriptions,public.alert_subscription_commands,public.notifications,public.push_devices,public.notification_deliveries from public,anon,authenticated,service_role;
