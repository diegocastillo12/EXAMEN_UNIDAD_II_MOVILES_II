revoke all on function public.read_qr_case(text) from public,anon,authenticated;
grant execute on function public.read_qr_case(text) to service_role;
revoke all on function public.revoke_case_public_link(text,uuid) from public,anon;
grant execute on function public.revoke_case_public_link(text,uuid) to authenticated;
-- Links and photo paths remain private; no new table grants or Storage policies.
