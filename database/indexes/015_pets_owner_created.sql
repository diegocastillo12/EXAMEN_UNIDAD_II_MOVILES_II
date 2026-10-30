create index if not exists pets_owner_created_idx on public.pets (owner_id, created_at desc, id);
