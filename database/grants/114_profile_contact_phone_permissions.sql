-- Existing owner RLS applies to this column; no public or peer profile access.
grant select(contact_phone), update(contact_phone) on public.profiles to authenticated;
revoke all on function public.read_case_contact(text,uuid) from public,anon;
grant execute on function public.read_case_contact(text,uuid) to authenticated;
