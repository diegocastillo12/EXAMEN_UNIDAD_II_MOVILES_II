create or replace function public.case_contact_visible(p_source text,p_id uuid)
returns boolean language sql stable security definer set search_path='' as $$
 select auth.uid() is not null and (
 (p_source='lost' and exists(select 1 from public.read_recovery_pet_case(p_id) r where r->>'status'='active'))
 or (p_source='found' and exists(select 1 from public.read_recovery_report(p_id) r where r->>'status'='active')));
$$;

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
  'suggested_name',case when v_owner=auth.uid() then (select display_name from public.profiles where id=auth.uid()) end);
end;
$$;

create or replace function public.set_case_contact(p_source text,p_id uuid,p_enabled boolean,p_name text,p_phone text,p_share_photo boolean,p_version bigint)
returns jsonb language plpgsql security definer set search_path='' set statement_timeout='5s' set lock_timeout='5s' as $$
declare v_owner uuid; v_contact public.case_contacts; v_name text; v_phone text;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='contact_forbidden';end if;
 if p_source='lost' then select owner_id into v_owner from public.lost_cases where id=p_id for update;
 elsif p_source='found' then select owner_id into v_owner from public.found_cases where id=p_id for update;
 else raise exception using errcode='23514',message='contact_invalid';end if;
 if v_owner is distinct from auth.uid() then raise exception using errcode='42501',message='contact_forbidden';end if;
 if p_enabled is null or p_share_photo is null or p_version is null or p_version<0 then raise exception using errcode='23514',message='contact_invalid';end if;
 v_name:=case when p_enabled then btrim(p_name) else '' end;
 v_phone:=case when p_enabled then p_phone else '' end;
 if p_enabled and (v_name is null or char_length(v_name) not between 2 and 80 or v_name ~ '[[:cntrl:]]' or v_phone is null or v_phone !~ '^\+[1-9][0-9]{7,14}$') then
  raise exception using errcode='23514',message='contact_invalid';end if;
 if p_enabled and not public.case_contact_visible(p_source,p_id) then raise exception using errcode='42501',message='contact_forbidden';end if;
 select * into v_contact from public.case_contacts where case_source=p_source and case_id=p_id for update;
 -- Exact retry after a lost response; never overwrite an intervening edit.
 if v_contact.version=p_version+1 and v_contact.enabled=p_enabled and v_contact.display_name=v_name and v_contact.phone=v_phone and v_contact.share_photo=(p_enabled and p_share_photo) then
  return public.read_case_contact(p_source,p_id);
 end if;
 if coalesce(v_contact.version,0)<>p_version then raise exception using errcode='40001',message='contact_conflict';end if;
 insert into public.case_contacts(case_source,case_id,owner_id,enabled,display_name,phone,share_photo,version)
 values(p_source,p_id,v_owner,p_enabled,v_name,v_phone,p_enabled and p_share_photo,p_version+1)
 on conflict(case_source,case_id) do update set enabled=excluded.enabled,display_name=excluded.display_name,phone=excluded.phone,
 share_photo=excluded.share_photo,version=excluded.version,updated_at=clock_timestamp();
 return public.read_case_contact(p_source,p_id);
end;
$$;

create or replace function public.can_read_case_contact_avatar(p_name text)
returns boolean language sql stable security definer set search_path='' as $$
 select auth.uid() is not null and exists(select 1 from public.case_contacts c
 where c.enabled and c.share_photo and p_name=c.owner_id::text||'/avatar.jpg'
 and public.case_contact_visible(c.case_source,c.case_id));
$$;
