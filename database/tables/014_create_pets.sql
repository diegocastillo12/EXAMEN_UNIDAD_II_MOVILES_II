create table if not exists public.pets (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80 and name = public.pet_trim(name)),
  species text not null check (species in ('dog','cat','other')),
  sex text check (sex in ('male','female')),
  age_months integer check (age_months between 0 and 600),
  traits text check (traits is null or (char_length(traits) between 1 and 500 and traits = public.pet_trim(traits))),
  version integer not null default 1 check (version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
