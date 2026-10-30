-- HU-10.1 / RF-11 / #36. Private evidence, no anonymous table or photo access.
create table if not exists public.public_sightings (
 id uuid primary key,
 case_source text not null,
 case_id uuid not null,
 request_hash text not null check(request_hash ~ '^[0-9a-f]{64}$'),
 actor_hash text not null check(actor_hash ~ '^[0-9a-f]{64}$'),
 observed_at timestamptz not null check(observed_at >= '2000-01-01'::timestamptz),
 received_at timestamptz not null default clock_timestamp(),
 latitude double precision not null check(latitude between -85 and 85),
 longitude double precision not null check(longitude between -180 and 180),
 location_source text not null check(location_source in ('manual','gps')),
 accuracy_meters double precision,
 comment text not null check(char_length(comment) <= 500),
 is_late boolean not null,
 evidence_jpeg bytea,
 foreign key(case_source,case_id) references public.case_public_links(case_source,case_id) on delete cascade,
 check((location_source='manual' and accuracy_meters is null) or (location_source='gps' and accuracy_meters between 0 and 100000 and accuracy_meters is not null)),
 check(observed_at <= received_at),
 check(evidence_jpeg is null or (octet_length(evidence_jpeg) between 4 and 1048576 and substring(evidence_jpeg from 1 for 2)='\xffd8'::bytea and substring(evidence_jpeg from octet_length(evidence_jpeg)-1 for 2)='\xffd9'::bytea))
);
create index if not exists public_sightings_actor_received on public.public_sightings(actor_hash,received_at);
create index if not exists public_sightings_case_received on public.public_sightings(case_source,case_id,received_at);
alter table public.public_sightings enable row level security;
revoke all on table public.public_sightings from public,anon,authenticated,service_role;
