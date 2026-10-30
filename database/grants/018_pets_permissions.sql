revoke all on public.pets from public, anon, authenticated;
grant select on public.pets to authenticated;
revoke all on function public.pet_trim(text) from public, anon, authenticated;
revoke all on function public.validate_pet_fields(text,text,text,integer,text) from public, anon, authenticated;
revoke all on function public.create_pet(uuid,text,text,text,integer,text) from public, anon, authenticated;
revoke all on function public.update_pet(uuid,integer,text,text,text,integer,text) from public, anon, authenticated;
grant execute on function public.create_pet(uuid,text,text,text,integer,text) to authenticated;
grant execute on function public.update_pet(uuid,integer,text,text,text,integer,text) to authenticated;
