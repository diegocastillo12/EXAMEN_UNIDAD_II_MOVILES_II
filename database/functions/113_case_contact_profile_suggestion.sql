-- Suggest private profile data only to the case author. Consent remains per case.
create or replace function public.read_case_contact(p_source text,p_id uuid)
returns jsonb language plpgsql stable security definer set search_path='' set statement_timeout='5s' as $$
declare v_owner uuid; v_contact public.case_contacts; v_visible boolean; v_data jsonb;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='contact_forbidden';end if;
 if p_source='lost' then select owner_id into v_owner from public.lost_cases where id=p_id and deleted_at is null;
 elsif p_source='found' then select owner_id into v_owner from public.found_cases where id=p_id and deleted_at is null;
 else raise exception using errcode='23514',message='contact_invalid';end if;
 v_visible:=public.case_contact_visible(p_source,p_id);
 select * into v_contact from public.case_contacts where case_source=p_source and case_id=p_id;
 if v_visible and v_contact.enabled and v_contact.owner_id=v_owner then
  v_data:=jsonb_build_object('display_name',v_contact.display_name,'phone',v_contact.phone,'share_photo',v_contact.share_photo,
   'avatar_path',case when v_contact.share_photo and exists(select 1 from storage.objects where bucket_id='profile-avatars' and name=v_owner::text||'/avatar.jpg') then v_owner::text||'/avatar.jpg' end);
 end if;
 return jsonb_build_object('contact',v_data,'can_edit',coalesce(v_owner=auth.uid(),false),
  'version',case when v_owner=auth.uid() then coalesce(v_contact.version,0) else 0 end,
  'suggested_name',case when v_owner=auth.uid() then (select display_name from public.profiles where id=auth.uid()) end,
  'suggested_phone',case when v_owner=auth.uid() then (select contact_phone from public.profiles where id=auth.uid()) end);
end;
$$;

