drop policy if exists saved_cases_owner_read on public.saved_cases;
create policy saved_cases_owner_read on public.saved_cases for select to authenticated
 using (owner_id=(select auth.uid()));
drop policy if exists saved_cases_owner_guard on public.saved_cases;
create policy saved_cases_owner_guard on public.saved_cases as restrictive for all to authenticated
 using (owner_id=(select auth.uid())) with check (owner_id=(select auth.uid()));
