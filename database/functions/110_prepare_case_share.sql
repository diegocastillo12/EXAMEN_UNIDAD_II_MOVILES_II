-- Sharing a visible public search does not confer ownership or poster commands.
create or replace function public.prepare_case_share(p_source text,p_id uuid)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='3s' set statement_timeout='8s' as $$
declare v_owner uuid;v_status text;v_deleted timestamptz;v_kind text;v_data jsonb;
 v_slug text;v_revoked timestamptz;v_projection jsonb;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='share_forbidden';end if;
 if p_source is null or p_source not in ('lost','found') or p_id is null then raise exception using errcode='23514',message='share_invalid';end if;
 if p_source='lost' then
  select owner_id,status,deleted_at into v_owner,v_status,v_deleted from public.lost_cases where id=p_id for share;
  v_kind:='own_loss';
  select r into v_data from public.read_recovery_pet_case(p_id) r;
 else
  select owner_id,status,deleted_at,report_kind into v_owner,v_status,v_deleted,v_kind from public.found_cases where id=p_id for share;
  select r into v_data from public.read_recovery_report(p_id) r;
 end if;
 if v_owner is null or v_deleted is not null or v_status<>'active' or v_kind not in ('own_loss','possible_loss','legacy_found')
 or v_data is null or jsonb_array_length(v_data->'photos')=0 then raise exception using errcode='23514',message='share_unavailable';end if;
 insert into public.case_public_links(case_source,case_id,owner_id) values(p_source,p_id,v_owner)
 on conflict(case_source,case_id) do nothing;
 select public_slug,revoked_at into v_slug,v_revoked from public.case_public_links where case_source=p_source and case_id=p_id and owner_id=v_owner for share;
 if v_slug is null or v_revoked is not null then raise exception using errcode='42501',message='share_forbidden';end if;
 -- Same public reader/verified photo checks as the actual shared destination.
 if public.read_qr_case(v_slug)->>'state'<>'active' then raise exception using errcode='23514',message='share_unavailable';end if;
 v_projection:=jsonb_build_object('source',p_source,'id',p_id,'public_slug',v_slug,'report_kind',v_kind,
  'name',coalesce(v_data->>'pet_name',''),'species',v_data->>'species','species_detail',v_data->>'species_detail',
  'size',v_data->>'size','sex',v_data->>'sex','traits',v_data->>'traits','occurred_at',v_data->'occurred_at',
  'photo_path',v_data->'photos'->0->>'path');
 return v_projection||jsonb_build_object('revision',md5(v_projection::text));
end;
$$;
