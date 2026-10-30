-- Locks share the case lifecycle order (pet -> case -> sighting).
create or replace function public.authorized_timeline_case(p_source text,p_case uuid)
returns text language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_status text;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='timeline_forbidden';end if;
 if p_source='lost' then
  perform 1 from public.pets p join public.lost_cases c on c.pet_id=p.id
   where c.id=p_case and c.owner_id=auth.uid() and p.deletion_requested_at is null for share of p;
  if found then
   select status into v_status from public.lost_cases where id=p_case and owner_id=auth.uid() and deleted_at is null for share;
  end if;
 elsif p_source='found' then
  select status into v_status from public.found_cases where id=p_case and owner_id=auth.uid() and deleted_at is null
   and report_kind in ('possible_loss','legacy_found') for share;
 end if;
 if v_status is null or v_status not in ('active','resolved') then raise exception using errcode='42501',message='timeline_forbidden';end if;
 return v_status;
end $$;

create or replace function public.can_read_case_timeline(p_source text,p_case uuid)
returns boolean language plpgsql security definer set search_path='' as $$
begin
 perform public.authorized_timeline_case(p_source,p_case);return true;
exception when insufficient_privilege then return false;
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
  where s.case_source=p_source and s.case_id=p_case
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
 if not found then raise exception using errcode='42501',message='timeline_forbidden';end if;
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
 if not found then raise exception using errcode='42501',message='timeline_forbidden';end if;
 perform public.authorized_timeline_case(s.case_source,s.case_id);
 return encode(s.evidence_jpeg,'base64');
end $$;

create or replace function public.review_sighting(p_command uuid,p_id uuid,p_expected_revision integer,p_state text,p_reason text)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare s public.public_sightings;r public.sighting_reviews;v_status text;v_revision integer;v_previous text;
begin
 select * into s from public.public_sightings where id=p_id;
 if not found then raise exception using errcode='42501',message='timeline_forbidden';end if;
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
