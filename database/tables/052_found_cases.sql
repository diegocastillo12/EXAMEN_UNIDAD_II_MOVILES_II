create table if not exists public.found_cases (
    id uuid primary key,
    owner_id uuid not null references auth.users(id),
    pet_id uuid references public.pets(id),
    status text not null default 'draft' check(status in ('draft','active','resolved','discarded')),
    occurred_at timestamptz,
    latitude double precision,
    longitude double precision,
    place_reference text,
    public_latitude double precision,
    public_longitude double precision,
    species text check(species in ('dog','cat','other')),
    species_detail text,
    size text check(size in ('small','medium','large')),
    sex text check(sex in ('male','female')),
    traits text,
    custody text check(custody in ('with_me','not_with_me')),
    photo_ids uuid[] not null,
    created_at timestamptz not null default clock_timestamp(),
    published_at timestamptz,
    constraint found_cases_no_inferred_pet check(pet_id is null),
    constraint found_cases_photo_count check(cardinality(photo_ids) between 1 and 3 and array_position(photo_ids,null) is null),
    constraint found_cases_active_fields check(status in ('draft','discarded') or (
        occurred_at is not null and occurred_at>='2000-01-01'::timestamptz and
        latitude is not null and latitude between -85 and 85 and longitude is not null and longitude between -180 and 180 and
        public_latitude is not null and public_longitude is not null and
        place_reference is not null and char_length(place_reference) between 1 and 120 and
        species is not null and (species<>'other' or (species_detail is not null and char_length(species_detail) between 1 and 40)) and
        traits is not null and char_length(traits) between 1 and 200 and published_at is not null))
);
create index if not exists found_cases_owner_idx on public.found_cases(owner_id,created_at desc);
create table if not exists public.found_case_photos (
    id uuid primary key,
    case_id uuid not null references public.found_cases(id),
    owner_id uuid not null references auth.users(id),
    content_hash text not null check(content_hash ~ '^[0-9a-f]{64}$'),
    processed_at timestamptz,
    status text not null default 'pending' check(status in ('pending','ready','removed')),
    created_at timestamptz not null default clock_timestamp()
);
create table if not exists public.found_case_events (
    case_id uuid not null references public.found_cases(id),
    actor_id uuid not null references auth.users(id),
    event_type text not null check(event_type='published'),
    created_at timestamptz not null default clock_timestamp(),
    primary key(case_id,event_type)
);
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values
    ('found-photo-renditions','found-photo-renditions',false,2097152,array['image/jpeg']),
    ('found-photo-thumbnails','found-photo-thumbnails',false,262144,array['image/jpeg'])
on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
