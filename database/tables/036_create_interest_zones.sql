-- HU-02.1 / RF-02,16. Coordinates are private preferences, never public QR data.
create table if not exists public.interest_zones (
    id uuid primary key,
    owner_id uuid not null references auth.users(id) on delete cascade,
    name text not null check (
        name = btrim(name, E' \t\n\r\f\v' || U&'\0085\00A0\1680\2000\2001\2002\2003\2004\2005\2006\2007\2008\2009\200A\2028\2029\202F\205F\3000\FEFF')
        and char_length(name) between 1 and 60
    ),
    latitude double precision not null check (latitude between -85 and 85),
    longitude double precision not null check (longitude between -180 and 180),
    radius_meters integer not null check (radius_meters between 100 and 50000),
    version integer not null default 1 check (version > 0),
    deleted_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create index if not exists interest_zones_owner_created_idx
    on public.interest_zones (owner_id, created_at, id) where deleted_at is null;
