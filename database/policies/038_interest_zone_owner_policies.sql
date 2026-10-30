alter table public.interest_zones enable row level security;
drop policy if exists interest_zones_select_own on public.interest_zones;
create policy interest_zones_select_own on public.interest_zones for select to authenticated
    using (owner_id = (select auth.uid()) and deleted_at is null);
-- Restrictive guard preserves privacy even if another permissive policy is added.
drop policy if exists interest_zones_owner_guard on public.interest_zones;
create policy interest_zones_owner_guard on public.interest_zones as restrictive for all to authenticated
    using (owner_id = (select auth.uid()) and deleted_at is null)
    with check (owner_id = (select auth.uid()) and deleted_at is null);
