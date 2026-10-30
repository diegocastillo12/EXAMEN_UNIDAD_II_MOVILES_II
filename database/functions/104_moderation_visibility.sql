-- HU-14.3: versioned evolution of public visibility; applied sources remain immutable.
create or replace function public.read_public_lost_case(p_id uuid)
returns table(id uuid,status text,occurred_at timestamptz,latitude double precision,longitude double precision,
    pet_name text,species text,species_detail text,size text,sex text,age_months integer,traits text,photos jsonb)
language sql stable security definer set search_path='' as $$
    select c.id,c.status,c.occurred_at,c.public_latitude,c.public_longitude,c.pet_name,c.species,c.species_detail,c.size,c.sex,c.age_months,c.traits,
        coalesce((select jsonb_agg(jsonb_build_object('id',ph.id,'path',ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg')
            order by ph.is_primary desc,ph.created_at,ph.id) from public.pet_photos ph
            where ph.id=any(c.photo_ids) and ph.status='published' and ph.processed_at is not null and ph.content_hash is not null),'[]'::jsonb)
    from public.lost_cases c where c.id=p_id and not public.is_moderation_hidden('lost',c.id) and c.deleted_at is null and (c.status='active' or (c.status='resolved' and c.owner_id=auth.uid()));
$$;

create or replace function public.read_public_found_case(p_id uuid)
returns table(id uuid,status text,occurred_at timestamptz,latitude double precision,longitude double precision,
    species text,species_detail text,size text,sex text,traits text,custody text,photos jsonb)
language sql stable security definer set search_path='' as $$
    select c.id,c.status,c.occurred_at,c.public_latitude,c.public_longitude,c.species,c.species_detail,c.size,c.sex,c.traits,c.custody,
        coalesce((select jsonb_agg(jsonb_build_object('id',ph.id,'path',ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg') order by ph.created_at,ph.id)
            from public.found_case_photos ph where ph.case_id=c.id and ph.id=any(c.photo_ids) and ph.status='ready' and ph.processed_at is not null),'[]'::jsonb)
    from public.found_cases c where c.id=p_id and not public.is_moderation_hidden('found',c.id) and c.deleted_at is null and (c.status='active' or (c.status='resolved' and c.owner_id=auth.uid()));
$$;

create or replace function public.is_public_case_rendition(p_name text)
returns boolean language sql stable security definer set search_path='' as $$
    select exists(select 1 from public.lost_cases c join public.pet_photos ph on ph.id=any(c.photo_ids) and ph.pet_id=c.pet_id
        where not public.is_moderation_hidden('lost',c.id) and c.deleted_at is null and c.status='active' and ph.status='published' and ph.processed_at is not null and ph.content_hash is not null
        and p_name=ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg');
$$;

create or replace function public.can_read_found_photo(p_name text)
returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.found_case_photos ph join public.found_cases c on c.id=ph.case_id
 where p_name=ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg' and
 (ph.owner_id=auth.uid() or (not public.is_moderation_hidden('found',c.id) and c.status='active' and c.deleted_at is null and ph.status='ready' and ph.processed_at is not null and ph.id=any(c.photo_ids)
 and (c.report_kind in ('legacy_found','possible_loss')
 or exists(select 1 from public.lost_cases target where target.id=c.target_lost_case_id and target.deleted_at is null and (target.status='active' or target.owner_id=auth.uid()))
 or exists(select 1 from public.found_cases target where target.id=c.target_community_case_id and target.report_kind='possible_loss'
 and target.deleted_at is null and (target.status='active' or target.owner_id=auth.uid()))))));
$$;

create or replace function public.read_qr_case(p_slug text)
returns jsonb language plpgsql stable security definer set search_path='' set statement_timeout='5s' as $$
declare v_link public.case_public_links; v_lost public.lost_cases; v_found public.found_cases;
 v_photos jsonb; v_payload jsonb; v_closed_at timestamptz;
begin
 if p_slug is null or p_slug !~ '^[0-9a-f]{64}$' then return jsonb_build_object('state','unavailable'); end if;
 select * into v_link from public.case_public_links where public_slug=p_slug and revoked_at is null;
 if not found then return jsonb_build_object('state','unavailable'); end if;
 if public.is_moderation_hidden(v_link.case_source,v_link.case_id) then return jsonb_build_object('state','unavailable');end if;
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

create or replace function public.read_case_timeline(p_source text,p_case uuid,p_before_time timestamptz default null,p_before_key text default null,p_limit integer default 20)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_status text;v_items jsonb;v_next jsonb;
begin
 v_status=public.authorized_timeline_case(p_source,p_case);
 if p_limit is null or p_limit not between 1 and 50 or (p_before_time is null)<>(p_before_key is null)
 or (p_before_time is not null and (not isfinite(p_before_time) or length(p_before_key)>80)) then
  raise exception using errcode='23514',message='timeline_invalid';end if;
 with events as (
  select 'sighting:'||s.id::text key,'sighting' kind,s.id::text id,s.observed_at,s.received_at,s.is_late,s.comment,
   s.evidence_jpeg is not null has_photo,coalesce(r.state,'unreviewed') review_state,coalesce(r.revision,0) revision
  from public.public_sightings s left join lateral
   (select state,revision from public.sighting_reviews where sighting_id=s.id order by revision desc limit 1) r on true
  where s.case_source=p_source and s.case_id=p_case and not public.is_moderation_hidden('sighting',s.id)
  union all
  select e.event_type,e.event_type,e.event_type,e.created_at,e.created_at,false,'',false,'unreviewed',0
   from public.case_events e where p_source='lost' and e.case_id=p_case
  union all
  select e.event_type,e.event_type,e.event_type,e.created_at,e.created_at,false,'',false,'unreviewed',0
   from public.found_case_events e where p_source='found' and e.case_id=p_case
 ), page as (
  select * from events where p_before_time is null or (observed_at,key)<(p_before_time,p_before_key)
  order by observed_at desc,key desc limit p_limit+1
 ), numbered as (select *,row_number() over(order by observed_at desc,key desc) n from page)
 select coalesce(jsonb_agg(to_jsonb(numbered)-'n' order by observed_at desc,key desc) filter(where n<=p_limit),'[]'::jsonb),
  case when count(*)>p_limit then (select jsonb_build_object('time',observed_at,'key',key) from numbered where n=p_limit) end
 into v_items,v_next from numbered;
 return jsonb_build_object('case_status',v_status,'items',v_items,'next',v_next);
end $$;

create or replace function public.read_sighting_review(p_id uuid,p_before_revision integer default null)
returns jsonb language plpgsql security definer set search_path='' as $$
declare s public.public_sightings;r public.sighting_reviews;v_status text;v_history jsonb;v_next integer;
begin
 select * into s from public.public_sightings where id=p_id;
 if not found or public.is_moderation_hidden('sighting',p_id) then raise exception using errcode='42501',message='timeline_forbidden';end if;
 v_status=public.authorized_timeline_case(s.case_source,s.case_id);
 if p_before_revision is not null and p_before_revision<1 then raise exception using errcode='23514',message='timeline_invalid';end if;
 select * into r from public.sighting_reviews where sighting_id=p_id order by revision desc limit 1;
 with page as (select * from public.sighting_reviews where sighting_id=p_id and (p_before_revision is null or revision<p_before_revision) order by revision desc limit 21),
 numbered as (select *,row_number() over(order by revision desc) n from page)
 select coalesce(jsonb_agg(to_jsonb(numbered)-'n' order by revision desc) filter(where n<=20),'[]'::jsonb),
  case when count(*)>20 then (select revision from numbered where n=20) end into v_history,v_next from numbered;
 return jsonb_build_object('id',s.id,'case_source',s.case_source,'case_id',s.case_id,'can_review',v_status='active',
  'observed_at',s.observed_at,'received_at',s.received_at,'is_late',s.is_late,'comment',s.comment,
  'latitude',s.latitude,'longitude',s.longitude,'location_source',s.location_source,'accuracy_meters',s.accuracy_meters,
  'has_photo',s.evidence_jpeg is not null,'review_state',coalesce(r.state,'unreviewed'),'revision',coalesce(r.revision,0),
  'history',v_history,'next_revision',v_next);
end $$;

create or replace function public.read_sighting_evidence(p_id uuid)
returns text language plpgsql security definer set search_path='' as $$
declare s public.public_sightings;
begin
 select * into s from public.public_sightings where id=p_id;
 if not found or public.is_moderation_hidden('sighting',p_id) then raise exception using errcode='42501',message='timeline_forbidden';end if;
 perform public.authorized_timeline_case(s.case_source,s.case_id);
 return encode(s.evidence_jpeg,'base64');
end $$;

create or replace function public.review_sighting(p_command uuid,p_id uuid,p_expected_revision integer,p_state text,p_reason text)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare s public.public_sightings;r public.sighting_reviews;v_status text;v_revision integer;v_previous text;
begin
 select * into s from public.public_sightings where id=p_id;
 if not found or public.is_moderation_hidden('sighting',p_id) then raise exception using errcode='42501',message='timeline_forbidden';end if;
 v_status=public.authorized_timeline_case(s.case_source,s.case_id);
 if p_command is null or p_command::text !~ '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
 or p_expected_revision is null or p_expected_revision<0 or p_expected_revision>=2147483647
 or p_state is null or p_state not in ('useful','doubtful','rejected','confirmed')
 or p_reason is null or char_length(public.pet_trim(p_reason)) not between 1 and 500 then raise exception using errcode='23514',message='timeline_invalid';end if;
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_command::text,27));
 select * into r from public.sighting_reviews where command_id=p_command;
 if found then
  if r.sighting_id<>p_id or r.actor_id<>auth.uid() or r.revision<>p_expected_revision+1 or r.state<>p_state or r.reason<>public.pet_trim(p_reason) then
   raise exception using errcode='40001',message='timeline_conflict';end if;
  return to_jsonb(r);
 end if;
 if v_status<>'active' then raise exception using errcode='23514',message='timeline_closed';end if;
 perform 1 from public.public_sightings where id=p_id for update;
 select revision,state into v_revision,v_previous from public.sighting_reviews where sighting_id=p_id order by revision desc limit 1;
 v_revision=coalesce(v_revision,0);v_previous=coalesce(v_previous,'unreviewed');
 if v_revision<>p_expected_revision then raise exception using errcode='40001',message='timeline_conflict';end if;
 if v_previous=p_state then raise exception using errcode='23514',message='timeline_transition';end if;
 insert into public.sighting_reviews(command_id,sighting_id,revision,previous_state,state,reason,actor_id)
 values(p_command,p_id,v_revision+1,v_previous,p_state,public.pet_trim(p_reason),auth.uid()) returning * into r;
 return to_jsonb(r);
end $$;

create or replace function public.persist_sighting(p_source text,p_case uuid,p_report jsonb,p_request_hash text,p_actor_hash text,p_evidence text default null,p_reporter uuid default null)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' set statement_timeout='10s' as $$
declare v_previous public.public_sightings; v_id uuid; v_observed timestamptz;
 v_lat double precision;v_lon double precision;v_accuracy double precision;v_source text;v_comment text;v_photo bytea;
 v_now timestamptz:=clock_timestamp();v_active boolean;v_pet uuid;v_late boolean;
begin
 if p_source is null or p_source not in ('lost','found') or p_case is null or p_request_hash is null or p_request_hash !~ '^[0-9a-f]{64}$'
 or p_actor_hash is null or p_actor_hash !~ '^[0-9a-f]{64}$' or p_report is null or jsonb_typeof(p_report)<>'object' then
  raise exception using errcode='23514',message='sighting_invalid'; end if;
 begin
  v_id=(p_report->>'id')::uuid;v_observed=(p_report->>'observedAt')::timestamptz;
  v_lat=(p_report->'point'->>'latitude')::double precision;v_lon=(p_report->'point'->>'longitude')::double precision;
  v_source=p_report->'point'->>'source';v_accuracy=(p_report->'point'->>'accuracy')::double precision;
  v_comment=btrim(p_report->>'comment');
  if p_evidence is not null then
   if length(p_evidence)>1398104 then raise exception 'invalid';end if;
   v_photo=decode(p_evidence,'base64');
  end if;
 exception when others then raise exception using errcode='23514',message='sighting_invalid';end;
 if v_id is null or v_id::text !~ '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
 or v_observed is null or not isfinite(v_observed) or v_observed<'2000-01-01' or v_observed>v_now
 or v_lat is null or not(v_lat between -85 and 85) or v_lon is null or not(v_lon between -180 and 180)
 or v_source is null or v_source not in ('manual','gps')
 or (v_source='manual' and v_accuracy is not null) or (v_source='gps' and (v_accuracy is null or not(v_accuracy between 0 and 100000)))
 or v_comment is null or char_length(v_comment)>500
 or (v_photo is not null and (octet_length(v_photo) not between 4 and 1048576 or substring(v_photo from 1 for 2)<>'\xffd8'::bytea or substring(v_photo from octet_length(v_photo)-1 for 2)<>'\xffd9'::bytea)) then
  raise exception using errcode='23514',message='sighting_invalid';end if;
 -- Lock retry key before budgets. Stable lock order and row locks serialize with revoke/close.
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_id::text,24));
 select * into v_previous from public.public_sightings where id=v_id;
 if found then
  if v_previous.case_source<>p_source or v_previous.case_id<>p_case or v_previous.request_hash<>p_request_hash or v_previous.actor_hash<>p_actor_hash or v_previous.reporter_id is distinct from p_reporter then
   raise exception using errcode='40001',message='sighting_conflict';end if;
  return jsonb_build_object('id',v_previous.id,'receivedAt',v_previous.received_at,'late',v_previous.is_late);
 end if;
 if p_source='lost' then
  select pet_id into v_pet from public.lost_cases where id=p_case;
  perform 1 from public.pets where id=v_pet and deletion_requested_at is null for share;
  v_active=found;
  perform 1 from public.lost_cases where id=p_case and status='active' and deleted_at is null for share;
  v_active=v_active and found;
 else
  perform 1 from public.found_cases where id=p_case and status='active' and deleted_at is null
   and report_kind in ('possible_loss','legacy_found') for share;
  v_active=found;
 end if;
 if public.is_moderation_hidden(p_source,p_case) then raise exception using errcode='40001',message='sighting_closed';end if;
 if not v_active then raise exception using errcode='40001',message='sighting_closed';end if;
 -- Persistent rolling budgets shared by replicas. HMAC is generated by the web server, never by visitors.
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_actor_hash,25));
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_source||p_case::text,26));
 if (select count(*) from public.public_sightings where actor_hash=p_actor_hash and received_at>v_now-interval '10 minutes')>=5
 or (select count(*) from public.public_sightings where case_source=p_source and case_id=p_case and received_at>v_now-interval '1 hour')>=30 then
  raise exception using errcode='54000',message='sighting_rate_limited';end if;
 v_late=v_observed<v_now-interval '24 hours';
 insert into public.public_sightings(id,case_source,case_id,request_hash,actor_hash,observed_at,received_at,latitude,longitude,location_source,accuracy_meters,comment,is_late,evidence_jpeg,reporter_id)
 values(v_id,p_source,p_case,p_request_hash,p_actor_hash,v_observed,v_now,v_lat,v_lon,v_source,v_accuracy,v_comment,v_late,v_photo,p_reporter);
 return jsonb_build_object('id',v_id,'receivedAt',v_now,'late',v_late);
end $$;

create or replace function public.guard_hidden_recovery_notice()
returns trigger language plpgsql security definer set search_path='' as $$
begin
 if new.status='active' and (
 public.is_moderation_hidden('lost',new.target_lost_case_id) or public.is_moderation_hidden('found',new.target_community_case_id)) then
  raise exception using errcode='23514',message='case_unavailable';end if;
 return new;
end $$;
revoke all on function public.guard_hidden_recovery_notice() from public,anon,authenticated,service_role;
drop trigger if exists hidden_recovery_notice_guard on public.found_cases;
create trigger hidden_recovery_notice_guard before insert or update of status,target_lost_case_id,target_community_case_id on public.found_cases
for each row execute function public.guard_hidden_recovery_notice();
