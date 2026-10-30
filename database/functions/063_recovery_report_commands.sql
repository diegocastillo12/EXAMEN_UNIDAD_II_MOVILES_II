-- Versioned replacement: target metadata can contain a 60-character registered pet type.
create or replace function public.publish_found_case(p_id uuid,p_occurred_at timestamptz,p_latitude double precision,p_longitude double precision,
    p_place_reference text,p_species text,p_species_detail text,p_size text,p_sex text,p_traits text,p_custody text,p_photo_ids uuid[])
returns setof public.found_cases language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_owner uuid:=auth.uid(); v_case public.found_cases; v_ids uuid[];
    v_place text:=public.pet_trim(p_place_reference); v_detail text:=nullif(public.pet_trim(p_species_detail),''); v_traits text:=public.pet_trim(p_traits);
begin
    if v_owner is null then raise exception using errcode='42501',message='found_unauthorized'; end if;
    select * into v_case from public.found_cases where id=p_id for update;
    if not found or v_case.owner_id<>v_owner then raise exception using errcode='42501',message='found_unauthorized'; end if;
    select coalesce(array_agg(id order by id),'{}'::uuid[]) into v_ids from (select distinct unnest(p_photo_ids) id) s;
    if v_case.status<>'draft' then
        if v_case.occurred_at=p_occurred_at and v_case.latitude=p_latitude and v_case.longitude=p_longitude and v_case.place_reference=v_place
            and v_case.species=p_species and v_case.species_detail is not distinct from v_detail and v_case.size is not distinct from p_size
            and v_case.sex is not distinct from p_sex and v_case.traits=v_traits and v_case.custody is not distinct from p_custody and v_case.photo_ids=v_ids then
            return next v_case; return;
        end if;
        raise exception using errcode='40001',message='found_conflict';
    end if;
    if p_occurred_at is null or p_occurred_at>clock_timestamp() or p_occurred_at<'2000-01-01'::timestamptz
        or p_latitude is null or not(p_latitude between -85 and 85) or p_longitude is null or not(p_longitude between -180 and 180)
        or v_place is null or char_length(v_place) not between 1 and 120 or p_species is null or p_species not in ('dog','cat','other')
        or (p_species='other' and (v_detail is null or char_length(v_detail) not between 1 and 60)) or (p_species<>'other' and v_detail is not null)
        or (p_size is not null and p_size not in ('small','medium','large')) or (p_sex is not null and p_sex not in ('male','female'))
        or v_traits is null or char_length(v_traits) not between 1 and 200 or (p_custody is not null and p_custody not in ('with_me','not_with_me'))
        or p_photo_ids is null or cardinality(p_photo_ids) not between (case when v_case.report_kind in ('sighting','with_reporter') then 0 else 1 end) and 3 or array_position(p_photo_ids,null) is not null
        or cardinality(v_ids)<>cardinality(p_photo_ids) or v_ids<>v_case.photo_ids then raise exception using errcode='23514',message='found_invalid'; end if;
    if (select count(*) from public.found_case_photos where case_id=p_id and owner_id=v_owner and id=any(v_ids) and status='ready' and processed_at is not null)<>cardinality(v_ids) then
        raise exception using errcode='23514',message='found_photos_unverified'; end if;
    update public.found_cases set status='active',occurred_at=p_occurred_at,latitude=p_latitude,longitude=p_longitude,place_reference=v_place,
        public_latitude=floor(p_latitude*100)/100+0.005,public_longitude=least(179.995,floor(p_longitude*100)/100+0.005),
        species=p_species,species_detail=v_detail,size=p_size,sex=p_sex,traits=v_traits,custody=p_custody,published_at=clock_timestamp()
        where id=p_id returning * into v_case;
    insert into public.found_case_events(case_id,actor_id,event_type) values(p_id,v_owner,'published');
    return next v_case;
end; $$;

create or replace function public.publish_recovery_report(p_id uuid,p_report_kind text,p_target_id uuid,p_community_target boolean,
 p_occurred_at timestamptz,p_latitude double precision,p_longitude double precision,p_place_reference text,
 p_species text,p_species_detail text,p_size text,p_sex text,p_traits text,p_custody text,p_photo_ids uuid[])
returns setof public.found_cases language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_case public.found_cases; v_lost public.lost_cases; v_community public.found_cases;
 v_species text:=p_species; v_detail text:=p_species_detail; v_size text:=p_size; v_sex text:=p_sex; v_saved public.found_cases;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='found_unauthorized'; end if;
 if p_report_kind='possible_loss' and char_length(public.pet_trim(p_species_detail))>40 then raise exception using errcode='23514',message='found_invalid'; end if;
 if p_report_kind is null or p_report_kind not in ('possible_loss','sighting','with_reporter') or p_community_target is null
 or (p_report_kind='possible_loss' and (p_target_id is not null or p_community_target))
 or (p_report_kind<>'possible_loss' and (p_target_id is null or p_target_id=p_id)) then
  raise exception using errcode='23514',message='found_invalid'; end if;
 -- Target first, report second: both publication and resolution serialize on the search.
 if p_report_kind<>'possible_loss' then
  if p_community_target then
   select * into v_community from public.found_cases where id=p_target_id for update;
   if not found or v_community.report_kind<>'possible_loss' then raise exception using errcode='23514',message='found_invalid'; end if;
   v_species:=v_community.species;v_detail:=v_community.species_detail;v_size:=v_community.size;v_sex:=v_community.sex;
  else
   select * into v_lost from public.lost_cases where id=p_target_id for update;
   if not found then raise exception using errcode='23514',message='found_invalid'; end if;
   v_species:=v_lost.species;v_detail:=v_lost.species_detail;v_size:=v_lost.size;v_sex:=v_lost.sex;
  end if;
 end if;
 select * into v_case from public.found_cases where id=p_id for update;
 if not found or v_case.owner_id<>auth.uid() then raise exception using errcode='42501',message='found_unauthorized'; end if;
 if v_case.deleted_at is not null then raise exception using errcode='40001',message='found_conflict'; end if;
 if v_case.status<>'draft' then
  if v_case.report_kind<>p_report_kind or v_case.target_lost_case_id is distinct from (case when not p_community_target then p_target_id end)
   or v_case.target_community_case_id is distinct from (case when p_community_target then p_target_id end) then
   raise exception using errcode='40001',message='found_conflict'; end if;
 elsif p_report_kind<>'possible_loss' and (
  (p_community_target and (v_community.status<>'active' or v_community.deleted_at is not null))
  or (not p_community_target and (v_lost.status<>'active' or v_lost.deleted_at is not null))) then
  raise exception using errcode='40001',message='found_target_closed';
 end if;
 if v_case.status='draft' then
  update public.found_cases set report_kind=p_report_kind,
   target_lost_case_id=case when not p_community_target then p_target_id end,
   target_community_case_id=case when p_community_target then p_target_id end where id=p_id;
 end if;
 -- Existing attestation/deduplication and identity checks stay authoritative.
 select * into v_saved from public.publish_found_case(p_id,p_occurred_at,p_latitude,p_longitude,p_place_reference,
  v_species,v_detail,v_size,v_sex,p_traits,
  case when p_report_kind='with_reporter' then 'with_me' when p_report_kind='sighting' then 'not_with_me' else null end,p_photo_ids);
 update public.found_cases set report_kind=p_report_kind,
  target_lost_case_id=case when not p_community_target then p_target_id end,
  target_community_case_id=case when p_community_target then p_target_id end where id=p_id returning * into v_saved;
 return next v_saved;
end $$;

create or replace function public.list_open_recovery_searches()
returns table(id uuid,community boolean,name text,species text,species_detail text,size text,sex text)
language sql stable security definer set search_path='' as $$
 select q.id,q.community,q.name,q.species,q.species_detail,q.size,q.sex from (
  select c.id,false community,c.pet_name name,c.species,c.species_detail,c.size,c.sex,c.created_at
   from public.lost_cases c where c.status='active' and c.deleted_at is null
  union all
  select c.id,true,coalesce(c.species_detail,case c.species when 'dog' then 'Perro' when 'cat' then 'Gato' else 'Otra especie' end),
   c.species,c.species_detail,c.size,c.sex,c.created_at from public.found_cases c
   where c.report_kind='possible_loss' and c.status='active' and c.deleted_at is null
 ) q where auth.uid() is not null order by q.created_at desc,q.id;
$$;

create or replace function public.resolve_recovery_search(p_id uuid,p_community boolean)
returns void language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_case public.lost_cases;v_report public.found_cases;v_pet uuid;
begin
 if auth.uid() is null or p_community is null then raise exception using errcode='42501',message='case_unauthorized'; end if;
 if p_community then
  select * into v_report from public.found_cases where id=p_id for update;
  if not found or v_report.owner_id<>auth.uid() or v_report.report_kind<>'possible_loss' or v_report.deleted_at is not null then
   raise exception using errcode='42501',message='case_unauthorized'; end if;
  if v_report.status='resolved' then return; end if;
  if v_report.status<>'active' then raise exception using errcode='40001',message='found_conflict'; end if;
  update public.found_cases set status='resolved' where id=p_id;
  insert into public.found_case_events(case_id,actor_id,event_type) values(p_id,auth.uid(),'resolved') on conflict(case_id,event_type) do nothing;
 else
  select pet_id into v_pet from public.lost_cases where id=p_id and owner_id=auth.uid() and deleted_at is null;
  if not found then raise exception using errcode='42501',message='case_unauthorized'; end if;
  perform 1 from public.pets where id=v_pet for update;
  select * into v_case from public.lost_cases where id=p_id for update;
  if v_case.owner_id<>auth.uid() or v_case.deleted_at is not null then raise exception using errcode='42501',message='case_unauthorized'; end if;
  if v_case.status='resolved' then return; end if;
  update public.lost_cases set status='resolved' where id=p_id;
  update public.pets set active_case_count=active_case_count-1,version=version+1,updated_at=clock_timestamp() where id=v_pet;
  insert into public.case_events(case_id,actor_id,event_type) values(p_id,auth.uid(),'resolved') on conflict(case_id,event_type) do nothing;
 end if;
end $$;

create or replace function public.prepare_recovery_report(p_id uuid,p_photo_ids uuid[],p_report_kind text,p_target_id uuid,p_community_target boolean)
returns void language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_owner uuid:=auth.uid();v_case public.found_cases;v_ids uuid[];
begin
 if v_owner is null then raise exception using errcode='42501',message='found_unauthorized'; end if;
 if p_id is null or p_photo_ids is null or p_report_kind is null or p_community_target is null
 or p_report_kind not in ('possible_loss','sighting','with_reporter') or array_position(p_photo_ids,null) is not null
 or cardinality(p_photo_ids) not between (case when p_report_kind='possible_loss' then 1 else 0 end) and 3
 or (p_report_kind='possible_loss' and (p_target_id is not null or p_community_target))
 or (p_report_kind<>'possible_loss' and (p_target_id is null or p_target_id=p_id)) then
  raise exception using errcode='23514',message='found_invalid'; end if;
 select coalesce(array_agg(id order by id),'{}'::uuid[]) into v_ids from (select distinct unnest(p_photo_ids) id) s;
 if cardinality(v_ids)<>cardinality(p_photo_ids) then raise exception using errcode='23514',message='found_invalid'; end if;
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_owner::text,14));
 select * into v_case from public.found_cases where id=p_id for update;
 if found then
  if v_case.owner_id<>v_owner then raise exception using errcode='42501',message='found_unauthorized'; end if;
  if v_case.status='discarded' or v_case.deleted_at is not null then raise exception using errcode='40001',message='found_conflict'; end if;
  if v_case.status<>'draft' then
   if v_case.photo_ids<>v_ids or v_case.report_kind<>p_report_kind
    or v_case.target_lost_case_id is distinct from (case when not p_community_target then p_target_id end)
    or v_case.target_community_case_id is distinct from (case when p_community_target then p_target_id end) then
     raise exception using errcode='40001',message='found_conflict'; end if;
   return;
  end if;
  update public.found_case_photos set status='removed' where case_id=p_id and not(id=any(v_ids));
  update public.found_cases set photo_ids=v_ids,report_kind=p_report_kind,
    target_lost_case_id=case when not p_community_target then p_target_id end,
    target_community_case_id=case when p_community_target then p_target_id end where id=p_id;
 else
  if (select count(*) from public.found_cases where owner_id=v_owner and status='draft')>=10 then raise exception using errcode='23514',message='found_draft_limit'; end if;
  insert into public.found_cases(id,owner_id,photo_ids,report_kind,target_lost_case_id,target_community_case_id)
  values(p_id,v_owner,v_ids,p_report_kind,case when not p_community_target then p_target_id end,case when p_community_target then p_target_id end);
 end if;
end $$;
