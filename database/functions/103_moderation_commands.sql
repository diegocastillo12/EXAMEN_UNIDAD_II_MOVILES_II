create or replace function public.require_content_reviewer()
returns uuid language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
begin
 perform 1 from public.content_report_reviewers where user_id=auth.uid() for share;
 if auth.uid() is null or not found then
  raise exception using errcode='42501',message='moderation_forbidden';end if;
 return auth.uid();
end $$;

create or replace function public.is_moderation_hidden(p_kind text,p_resource uuid)
returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.content_visibility where resource_kind=p_kind and resource_id=p_resource and hidden)
 or (p_kind='found' and exists(select 1 from public.found_cases c join public.content_visibility v
 on (v.resource_kind='lost' and v.resource_id=c.target_lost_case_id) or (v.resource_kind='found' and v.resource_id=c.target_community_case_id)
 where c.id=p_resource and v.hidden))
 or (p_kind='sighting' and exists(select 1 from public.public_sightings s join public.content_visibility v
 on v.resource_kind=s.case_source and v.resource_id=s.case_id where s.id=p_resource and v.hidden));
$$;

create or replace function public.list_moderation_reports(p_resolved boolean default false,p_before_time timestamptz default null,p_before_id uuid default null)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=public.require_content_reviewer();v_items jsonb;v_next jsonb;
begin
 if p_resolved is null or (p_before_time is null)<>(p_before_id is null) or (p_before_time is not null and not isfinite(p_before_time)) then
  raise exception using errcode='23514',message='moderation_invalid';end if;
 insert into public.content_moderation_access(actor_id,action) values(v_actor,'queue');
 with page as (
  select r.id,r.resource_kind,r.resource_id,r.submitted_at,coalesce(s.version,0) version
  from public.content_reports r left join public.content_report_resolutions s on s.report_id=r.id
  where (s.report_id is not null)=p_resolved and (p_before_time is null or (r.submitted_at,r.id)<(p_before_time,p_before_id))
  order by r.submitted_at desc,r.id desc limit 21
 ), numbered as(select *,row_number() over(order by submitted_at desc,id desc) n from page)
 select coalesce(jsonb_agg(to_jsonb(numbered)-'n' order by submitted_at desc,id desc) filter(where n<=20),'[]'::jsonb),
 case when count(*)>20 then (select jsonb_build_object('time',submitted_at,'id',id) from numbered where n=20) end
 into v_items,v_next from numbered;
 return jsonb_build_object('items',v_items,'next',v_next);
end $$;

create or replace function public.read_moderation_report(p_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=public.require_content_reviewer();r public.content_reports;v_resource jsonb;v_history jsonb;
begin
 select * into r from public.content_reports where id=p_id;
 if not found then raise exception using errcode='42501',message='moderation_forbidden';end if;
 insert into public.content_moderation_access(actor_id,report_id,action) values(v_actor,p_id,'detail');
 if r.resource_kind='lost' then
  select jsonb_build_object('title',pet_name,'text',traits,'status',status,'removed',deleted_at is not null,
  'has_photo',exists(select 1 from public.pet_photos ph where ph.id=any(c.photo_ids) and ph.status='published' and ph.processed_at is not null))
  into v_resource from public.lost_cases c where id=r.resource_id;
 elsif r.resource_kind='found' then
  select jsonb_build_object('title',case when report_kind='possible_loss' then 'Búsqueda comunitaria' else 'Aviso' end,'text',traits,'status',status,'removed',deleted_at is not null,
  'has_photo',exists(select 1 from public.found_case_photos ph where ph.id=any(c.photo_ids) and ph.status='ready' and ph.processed_at is not null))
  into v_resource from public.found_cases c where id=r.resource_id;
 else
  select jsonb_build_object('title','Avistamiento','text',comment,'status','received','removed',false,'has_photo',evidence_jpeg is not null)
  into v_resource from public.public_sightings where id=r.resource_id;
 end if;
 select coalesce(jsonb_agg(to_jsonb(d) order by report_version desc),'[]'::jsonb) into v_history
 from (select * from public.content_moderation_decisions where report_id=p_id order by report_version desc limit 20) d;
 return jsonb_build_object('report',to_jsonb(r),'resource',v_resource,
  'report_version',coalesce((select version from public.content_report_resolutions where report_id=p_id),0),
  'resource_version',coalesce((select version from public.content_visibility where resource_kind=r.resource_kind and resource_id=r.resource_id),0),
  'hidden',coalesce((select hidden from public.content_visibility where resource_kind=r.resource_kind and resource_id=r.resource_id),false),
  'effective_hidden',public.is_moderation_hidden(r.resource_kind,r.resource_id),'history',v_history);
end $$;

-- Explicit access to the primary processed photo only. No original uploads or coordinates.
create or replace function public.read_moderation_evidence(p_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=public.require_content_reviewer();r public.content_reports;v_photo jsonb;
begin
 select * into r from public.content_reports where id=p_id;
 if not found then raise exception using errcode='42501',message='moderation_forbidden';end if;
 insert into public.content_moderation_access(actor_id,report_id,action) values(v_actor,p_id,'evidence');
 if r.resource_kind='sighting' then
  select jsonb_build_object('jpeg',encode(evidence_jpeg,'base64')) into v_photo from public.public_sightings where id=r.resource_id and evidence_jpeg is not null;
 elsif r.resource_kind='lost' then
  select jsonb_build_object('bucket','pet-photo-renditions','path',ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg') into v_photo
  from public.lost_cases c join public.pet_photos ph on ph.id=any(c.photo_ids) and ph.pet_id=c.pet_id and ph.owner_id=c.owner_id
  where c.id=r.resource_id and ph.status='published' and ph.processed_at is not null and ph.content_hash is not null order by ph.is_primary desc,ph.created_at,ph.id limit 1;
 else
  select jsonb_build_object('bucket','found-photo-renditions','path',ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg') into v_photo
  from public.found_cases c join public.found_case_photos ph on ph.id=any(c.photo_ids) and ph.case_id=c.id and ph.owner_id=c.owner_id
  where c.id=r.resource_id and ph.status='ready' and ph.processed_at is not null and ph.content_hash is not null order by ph.created_at,ph.id limit 1;
 end if;
 return v_photo;
end $$;

create or replace function public.decide_content_report(p_command uuid,p_report uuid,p_report_version integer,p_resource_version integer,p_action text,p_reason text)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' set statement_timeout='10s' as $$
declare v_actor uuid:=public.require_content_reviewer();r public.content_reports;d public.content_moderation_decisions;
 v_report_version integer;v_resource_version integer;v_hidden boolean;v_reason text:=public.pet_trim(p_reason);
begin
 if p_command is null or p_command::text !~ '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
 or p_report is null or p_report_version is null or p_report_version<0 or p_resource_version is null or p_resource_version<0
 or p_action is null or p_action not in ('hide','show','dismiss') or v_reason is null or char_length(v_reason) not between 1 and 500 then
  raise exception using errcode='23514',message='moderation_invalid';end if;
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('moderation_command:'||p_command::text,0));
 select * into d from public.content_moderation_decisions where command_id=p_command;
 if found then
  if d.actor_id<>v_actor or d.report_id<>p_report or d.action<>p_action or d.reason<>v_reason
   or d.report_version<>p_report_version+1 or d.resource_version<>p_resource_version+1 then
   raise exception using errcode='40001',message='moderation_conflict';end if;
  return to_jsonb(d);
 end if;
 select * into r from public.content_reports where id=p_report;
 if not found then raise exception using errcode='42501',message='moderation_forbidden';end if;
 -- All reports for one resource serialize; CAS protects decisions made from stale detail.
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('moderation_resource:'||r.resource_kind||r.resource_id::text,0));
 select coalesce((select version from public.content_report_resolutions where report_id=p_report),0),
 coalesce((select version from public.content_visibility where resource_kind=r.resource_kind and resource_id=r.resource_id),0),
 coalesce((select hidden from public.content_visibility where resource_kind=r.resource_kind and resource_id=r.resource_id),false)
 into v_report_version,v_resource_version,v_hidden;
 if v_report_version<>p_report_version or v_resource_version<>p_resource_version then
  raise exception using errcode='40001',message='moderation_conflict';end if;
 v_hidden=case p_action when 'hide' then true when 'show' then false else v_hidden end;
 insert into public.content_visibility values(r.resource_kind,r.resource_id,v_hidden,v_resource_version+1)
 on conflict(resource_kind,resource_id) do update set hidden=excluded.hidden,version=excluded.version;
 insert into public.content_report_resolutions(report_id,version) values(p_report,v_report_version+1)
 on conflict(report_id) do update set version=excluded.version,resolved_at=clock_timestamp();
 insert into public.content_moderation_decisions(command_id,report_id,actor_id,action,reason,report_version,resource_version,hidden)
 values(p_command,p_report,v_actor,p_action,v_reason,v_report_version+1,v_resource_version+1,v_hidden) returning * into d;
 insert into public.content_moderation_access(actor_id,report_id,action) values(v_actor,p_report,'decision');
 return to_jsonb(d);
end $$;

-- Replace reviewer reads from029 so every privileged read is audited.
create or replace function public.read_content_report(p_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare r public.content_reports;v_actor uuid:=auth.uid();
begin
 if v_actor is null then raise exception using errcode='42501',message='report_forbidden';end if;
 select * into r from public.content_reports where id=p_id;
 if not found then raise exception using errcode='42501',message='report_forbidden';end if;
 if r.reporter_id<>v_actor then
  if not exists(select 1 from public.content_report_reviewers where user_id=v_actor) then
   raise exception using errcode='42501',message='report_forbidden';end if;
  perform public.require_content_reviewer();
  insert into public.content_moderation_access(actor_id,report_id,action) values(v_actor,p_id,'detail');
 end if;
 return to_jsonb(r);
end $$;
