revoke all on public.interest_zones from public, anon, authenticated;
grant select (id, owner_id, name, latitude, longitude, radius_meters, version, created_at, updated_at)
    on public.interest_zones to authenticated;
revoke all on function public.save_interest_zone(uuid, integer, text, double precision, double precision, integer)
    from public, anon, authenticated;
revoke all on function public.delete_interest_zone(uuid, integer) from public, anon, authenticated;
grant execute on function public.save_interest_zone(uuid, integer, text, double precision, double precision, integer)
    to authenticated;
grant execute on function public.delete_interest_zone(uuid, integer) to authenticated;
