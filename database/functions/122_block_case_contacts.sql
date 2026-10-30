-- HU-14.2: a block in either direction suppresses the per-case contact,
-- including the shared avatar, through the existing read/Storage adapter.
-- Preserve consent and owner editing; unblocking never publishes a new contact.
create or replace function public.case_contact_visible(p_source text,p_id uuid)
returns boolean language sql stable security definer set search_path='' as $$
 select auth.uid() is not null and (
  (p_source='lost' and exists(
   select 1 from public.lost_cases c where c.id=p_id
   and not public.users_have_block(auth.uid(),c.owner_id)
   and exists(select 1 from public.read_recovery_pet_case(p_id) r where r->>'status'='active')))
  or (p_source='found' and exists(
   select 1 from public.found_cases c where c.id=p_id
   and not public.users_have_block(auth.uid(),c.owner_id)
   and exists(select 1 from public.read_recovery_report(p_id) r where r->>'status'='active'))));
$$;
revoke all on function public.case_contact_visible(text,uuid) from public,anon,authenticated,service_role;
