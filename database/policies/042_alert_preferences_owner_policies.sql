alter table public.alert_preferences enable row level security;
drop policy if exists alert_preferences_owner_read on public.alert_preferences;
create policy alert_preferences_owner_read on public.alert_preferences for select to authenticated
    using (owner_id = (select auth.uid()));
drop policy if exists alert_preferences_owner_guard on public.alert_preferences;
create policy alert_preferences_owner_guard on public.alert_preferences as restrictive for all to authenticated
    using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
