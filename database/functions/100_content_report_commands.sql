create or replace function public.authorize_report_resource(p_kind text,p_resource uuid)
returns void language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_visible boolean; s public.public_sightings;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='report_forbidden';end if;
 if p_kind='lost' then
  select exists(select 1 from public.read_recovery_pet_case(p_resource)) into v_visible;
 elsif p_kind='found' then
  select exists(select 1 from public.read_recovery_report(p_resource)) into v_visible;
 elsif p_kind='sighting' then
  select * into s from public.public_sightings where id=p_resource;
  if found then
   -- Sightings are private; only the responsible account can view/report them.
   v_visible=public.can_read_case_timeline(s.case_source,s.case_id);
  end if;
 end if;
 if not coalesce(v_visible,false) then raise exception using errcode='42501',message='report_forbidden';end if;
end $$;

create or replace function public.submit_content_report(p_command uuid,p_kind text,p_resource uuid,p_reason text,p_evidence_note text default null)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' set statement_timeout='10s' as $$
declare v_actor uuid:=auth.uid();r public.content_reports;v_reason text:=public.pet_trim(p_reason);v_note text:=nullif(public.pet_trim(p_evidence_note),'');
begin
 if v_actor is null then raise exception using errcode='42501',message='report_forbidden';end if;
 if p_command is null or p_command::text !~ '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
 or p_kind is null or p_kind not in ('lost','found','sighting') or p_resource is null
 or v_reason is null or char_length(v_reason) not between 1 and 500 or char_length(v_note)>1000 then
  raise exception using errcode='23514',message='report_invalid';end if;
 -- Serialize UUID retries, including the first request and requests by another actor.
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('content_report:'||p_command::text,0));
 select * into r from public.content_reports where id=p_command;
 if found then
  if r.reporter_id<>v_actor then raise exception using errcode='42501',message='report_forbidden';end if;
  if r.resource_kind<>p_kind or r.resource_id<>p_resource or r.reason<>v_reason or r.evidence_note is distinct from v_note then
   raise exception using errcode='40001',message='report_conflict';end if;
  -- A receipt remains replayable if the resource later closes or disappears.
  return to_jsonb(r);
 end if;
 perform public.authorize_report_resource(p_kind,p_resource);
 insert into public.content_reports(id,reporter_id,resource_kind,resource_id,reason,evidence_note)
 values(p_command,v_actor,p_kind,p_resource,v_reason,v_note) returning * into r;
 return to_jsonb(r);
end $$;

create or replace function public.read_content_report(p_id uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare r public.content_reports;v_actor uuid:=auth.uid();
begin
 if v_actor is null then raise exception using errcode='42501',message='report_forbidden';end if;
 select * into r from public.content_reports where id=p_id;
 if not found or (r.reporter_id<>v_actor and not exists(select 1 from public.content_report_reviewers where user_id=v_actor)) then
  raise exception using errcode='42501',message='report_forbidden';end if;
 return to_jsonb(r);
end $$;
