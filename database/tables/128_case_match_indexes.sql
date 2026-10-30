-- HU-25/HU-26: server-only visual indexes and per-responsible human reviews.
create table if not exists public.case_match_embeddings (
 case_source text not null check(case_source in ('lost','found')),
 case_id uuid not null,
 photo_id uuid not null,
 photo_hash text not null check(photo_hash ~ '^[0-9a-f]{64}$'),
 case_revision text not null check(case_revision ~ '^[0-9a-f]{32}$'),
 model_version text not null check(model_version='clip-vit-b32-d15189d-q8-v1'),
 embedding real[] not null check(cardinality(embedding)=512 and array_ndims(embedding)=1 and array_lower(embedding,1)=1 and array_position(embedding,null) is null),
 indexed_at timestamptz not null default clock_timestamp(),
 primary key(case_source,case_id,photo_id,model_version)
);
create table if not exists public.case_match_reviews (
 command_id uuid primary key,
 actor_id uuid not null references auth.users(id),
 anchor_source text not null check(anchor_source in ('lost','found')),
 anchor_id uuid not null,
 anchor_revision text not null check(anchor_revision ~ '^[0-9a-f]{32}$'),
 candidate_source text not null check(candidate_source in ('lost','found')),
 candidate_id uuid not null,
 candidate_revision text not null check(candidate_revision ~ '^[0-9a-f]{32}$'),
 model_version text not null check(model_version='clip-vit-b32-d15189d-q8-v1'),
 decision text not null check(decision in ('confirmed','dismissed')),
 reviewed_at timestamptz not null default clock_timestamp()
);
create index if not exists case_match_reviews_latest on public.case_match_reviews(actor_id,anchor_source,anchor_id,candidate_source,candidate_id,reviewed_at desc);
alter table public.case_match_embeddings enable row level security;
alter table public.case_match_reviews enable row level security;
revoke all on public.case_match_embeddings,public.case_match_reviews from public,anon,authenticated,service_role;
