alter table public.pets add column if not exists photo_selection_version integer not null default 0 check(photo_selection_version >= 0);
alter table public.pet_photos add column if not exists is_primary boolean not null default false;
alter table public.pet_photos add column if not exists processed_at timestamptz;
alter table public.pet_photos add column if not exists content_hash text check(content_hash ~ '^[0-9a-f]{64}$');
alter table public.pet_photos drop constraint if exists pet_photos_status_check;
alter table public.pet_photos add constraint pet_photos_status_check check(status in ('pending','published','removing'));
create unique index if not exists pet_photos_one_primary_idx on public.pet_photos(pet_id) where is_primary;
-- Existing photos remain private and unverified; never invent processed_at.
update public.pet_photos ph set is_primary=true where ph.id in (
    select distinct on (pet_id) id from public.pet_photos candidate
    where status='published' and not exists (
        select 1 from public.pet_photos selected where selected.pet_id=candidate.pet_id and selected.is_primary
    ) order by pet_id,created_at,id
);
create table if not exists public.pet_photo_deletions (
    id uuid primary key,
    pet_id uuid not null references public.pets(id) on delete cascade,
    owner_id uuid not null references auth.users(id) on delete cascade
);
alter table public.pet_photo_deletions enable row level security;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('pet-photo-renditions','pet-photo-renditions',false,2097152,array['image/jpeg']),
       ('pet-photo-thumbnails','pet-photo-thumbnails',false,262144,array['image/jpeg'])
on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
