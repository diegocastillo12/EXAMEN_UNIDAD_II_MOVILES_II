revoke all on table public.alert_preferences from public, anon, authenticated;
grant select (owner_id, version, enabled, lost_pets, found_pets, case_updates, in_app, push)
    on public.alert_preferences to authenticated;
revoke all on function public.save_alert_preferences(integer, boolean, boolean, boolean, boolean, boolean, boolean)
    from public, anon, authenticated;
grant execute on function public.save_alert_preferences(integer, boolean, boolean, boolean, boolean, boolean, boolean)
    to authenticated;
