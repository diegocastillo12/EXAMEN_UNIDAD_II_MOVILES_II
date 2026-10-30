-- HU-09 / RF-09. Server-only resolver. photo_objects must NEVER reach a browser.
create or replace function public.read_qr_case(p_slug text)
returns jsonb language plpgsql stable security definer set search_path='' set statement_timeout='5s' as $$
declare v_link public.case_public_links; v_lost public.lost_cases; v_found public.found_cases;
 v_photos jsonb; v_payload jsonb; v_closed_at timestamptz;
begin
 if p_slug is null or p_slug !~ '^[0-9a-f]{64}$' then return jsonb_build_object('state','unavailable'); end if;
 select * into v_link from public.case_public_links where public_slug=p_slug and revoked_at is null;
 if not found then return jsonb_build_object('state','unavailable'); end if;
 if v_link.case_source='lost' then
  select * into v_lost from public.lost_cases where id=v_link.case_id and owner_id=v_link.owner_id and deleted_at is null;
  if not found or not exists(select 1 from public.pets where id=v_lost.pet_id and owner_id=v_link.owner_id and deletion_requested_at is null) then
   return jsonb_build_object('state','unavailable'); end if;
  if v_lost.status='resolved' then
   select created_at into v_closed_at from public.case_events where case_id=v_lost.id and event_type='resolved';
   return jsonb_build_object('state','closed','resolution','resolved','closed_at',v_closed_at);
  end if;
  if v_lost.status<>'active' then return jsonb_build_object('state','unavailable'); end if;
  select coalesce(jsonb_agg(jsonb_build_object('bucket','pet-photo-renditions','path',ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg')
   order by ph.is_primary desc,ph.created_at,ph.id),'[]'::jsonb) into v_photos
   from public.pet_photos ph where ph.id=any(v_lost.photo_ids) and ph.pet_id=v_lost.pet_id and ph.owner_id=v_link.owner_id
   and ph.status='published' and ph.processed_at is not null and ph.content_hash is not null
   and exists(select 1 from storage.objects o where o.bucket_id='pet-photo-renditions'
    and o.name=ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg'
    and o.metadata->>'mimetype'='image/jpeg' and (o.metadata->>'size')::bigint between 1 and 2097152);
  v_payload=jsonb_build_object('kind','lost','name',v_lost.pet_name,'species',v_lost.species,'species_detail',v_lost.species_detail,
   'size',v_lost.size,'sex',v_lost.sex,'traits',v_lost.traits,'occurred_at',v_lost.occurred_at,
   'area',jsonb_build_object('latitude',round(v_lost.public_latitude::numeric,2),'longitude',round(v_lost.public_longitude::numeric,2)));
 else
  select * into v_found from public.found_cases where id=v_link.case_id and owner_id=v_link.owner_id and deleted_at is null
   and report_kind in ('possible_loss','legacy_found');
  if not found then return jsonb_build_object('state','unavailable'); end if;
  if v_found.status='resolved' then
   select created_at into v_closed_at from public.found_case_events where case_id=v_found.id and event_type='resolved';
   return jsonb_build_object('state','closed','resolution','resolved','closed_at',v_closed_at);
  end if;
  if v_found.status<>'active' then return jsonb_build_object('state','unavailable'); end if;
  select coalesce(jsonb_agg(jsonb_build_object('bucket','found-photo-renditions','path',ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg')
   order by ph.created_at,ph.id),'[]'::jsonb) into v_photos
   from public.found_case_photos ph where ph.id=any(v_found.photo_ids) and ph.case_id=v_found.id and ph.owner_id=v_link.owner_id
   and ph.status='ready' and ph.processed_at is not null and ph.content_hash is not null
   and exists(select 1 from storage.objects o where o.bucket_id='found-photo-renditions'
    and o.name=ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg'
    and o.metadata->>'mimetype'='image/jpeg' and (o.metadata->>'size')::bigint between 1 and 2097152);
  v_payload=jsonb_build_object('kind',case when v_found.report_kind='possible_loss' then 'lost' else 'found' end,
   'name','','species',v_found.species,'species_detail',v_found.species_detail,'size',v_found.size,'sex',v_found.sex,
   'traits',v_found.traits,'occurred_at',v_found.occurred_at,
   'area',jsonb_build_object('latitude',round(v_found.public_latitude::numeric,2),'longitude',round(v_found.public_longitude::numeric,2)));
 end if;
 if jsonb_array_length(v_photos)=0 then return jsonb_build_object('state','unavailable'); end if;
 return v_payload||jsonb_build_object('state','active','photo_objects',v_photos);
end $$;
