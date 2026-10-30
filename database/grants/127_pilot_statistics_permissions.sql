revoke all on function public.require_platform_administrator() from public,anon,authenticated,service_role;
revoke all on function public.read_pilot_statistics(date,date) from public,anon,authenticated,service_role;
grant execute on function public.require_platform_administrator() to authenticated;
grant execute on function public.read_pilot_statistics(date,date) to authenticated;
