create table if not exists public.pet_photos (
  id uuid primary key,
  pet_id uuid not null references public.pets(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check(status in ('pending','published')),
  created_at timestamptz not null default now()
);
create index if not exists pet_photos_pet_created_idx on public.pet_photos(pet_id,created_at,id);
