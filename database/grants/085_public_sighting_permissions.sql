revoke all on function public.submit_public_sighting(text,jsonb,text,text,text) from public,anon,authenticated;
grant execute on function public.submit_public_sighting(text,jsonb,text,text,text) to service_role;
