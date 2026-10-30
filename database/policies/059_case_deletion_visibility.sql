drop policy if exists lost_cases_owner_read on public.lost_cases;
create policy lost_cases_owner_read on public.lost_cases for select to authenticated using(owner_id=auth.uid() and deleted_at is null);
