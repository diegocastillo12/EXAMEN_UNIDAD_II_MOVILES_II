create or replace function public.read_case_closure(p_source text,p_case uuid)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_status text;v_receipt jsonb;
begin
 v_status=public.authorized_timeline_case(p_source,p_case);
 if p_source='found' and not exists(select 1 from public.found_cases where id=p_case and report_kind='possible_loss') then
  raise exception using errcode='42501',message='closure_forbidden';end if;
 select to_jsonb(c) into v_receipt from public.case_closures c where case_source=p_source and case_id=p_case;
 return jsonb_build_object('status',v_status,'receipt',v_receipt);
end $$;

create or replace function public.close_recovery_case(p_command uuid,p_source text,p_case uuid,p_reason text,p_evidence_note text default null)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_status text;v_old public.case_closures;v_new public.case_closures;v_pet uuid;
 v_reason text:=public.pet_trim(p_reason);
 v_note text:=nullif(public.pet_trim(p_evidence_note),'');
begin
 if auth.uid() is null then raise exception using errcode='42501',message='closure_forbidden';end if;
 if p_command is null or p_source is null or p_source not in ('lost','found') or p_case is null
 or v_reason is null or char_length(v_reason) not between 1 and 500 or char_length(v_note)>500 then
  raise exception using errcode='23514',message='closure_invalid';end if;
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_command::text,13));
 -- Same order as publication, sightings, review and deletion: pet -> case.
 if p_source='lost' then
  select pet_id into v_pet from public.lost_cases where id=p_case and owner_id=auth.uid() and deleted_at is null;
  if not found then raise exception using errcode='42501',message='closure_forbidden';end if;
  perform 1 from public.pets where id=v_pet and deletion_requested_at is null for update;
  if not found then raise exception using errcode='42501',message='closure_forbidden';end if;
  select status into v_status from public.lost_cases where id=p_case and owner_id=auth.uid() and deleted_at is null for update;
 else
  select status into v_status from public.found_cases where id=p_case and owner_id=auth.uid() and deleted_at is null and report_kind='possible_loss' for update;
 end if;
 if v_status is null then raise exception using errcode='42501',message='closure_forbidden';end if;
 select * into v_old from public.case_closures where command_id=p_command;
 if found then
  if (v_old.actor_id,v_old.case_source,v_old.case_id,v_old.reason,v_old.evidence_note)
   is distinct from (auth.uid(),p_source,p_case,v_reason,v_note) then
   raise exception using errcode='40001',message='closure_conflict';end if;
  return to_jsonb(v_old);
 end if;
 if v_status<>'active' then raise exception using errcode='40001',message='closure_closed';end if;
 insert into public.case_closures(command_id,case_source,case_id,actor_id,reason,evidence_note)
 values(p_command,p_source,p_case,auth.uid(),v_reason,v_note) returning * into v_new;
 if p_source='lost' then
  update public.lost_cases set status='resolved' where id=p_case;
  update public.pets set active_case_count=active_case_count-1,version=version+1,updated_at=clock_timestamp() where id=v_pet;
  insert into public.case_events(case_id,actor_id,event_type,created_at) values(p_case,auth.uid(),'resolved',v_new.closed_at);
 else
  update public.found_cases set status='resolved' where id=p_case;
  insert into public.found_case_events(case_id,actor_id,event_type,created_at) values(p_case,auth.uid(),'resolved',v_new.closed_at);
 end if;
 -- Keep the inbox as history; cancel search work (including leases) atomically.
 -- A push already accepted/in transit cannot be recalled; closure notices remain eligible.
 update public.notification_deliveries d set status='cancelled',last_error='case_closed',lease=null,leased_until=null
 from public.notifications n where n.id=d.notification_id and n.case_source=p_source and n.case_id=p_case
 and n.kind<>'resolved' and d.status='pending';
 return to_jsonb(v_new);
end $$;

-- Compatibility for installed clients: affirmative action supplies a truthful reason.
-- Existing closures are preserved without fabricated receipts or backfill.
create or replace function public.resolve_recovery_search(p_id uuid,p_community boolean)
returns void language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_source text;
begin
 if p_community is null then raise exception using errcode='42501',message='case_unauthorized';end if;
 v_source=case when p_community then 'found' else 'lost' end;
 perform public.close_recovery_case(gen_random_uuid(),v_source,p_id,'Recuperación confirmada por el responsable',null);
exception
 when insufficient_privilege then raise exception using errcode='42501',message='case_unauthorized';
 when serialization_failure then
  if sqlerrm<>'closure_closed' then raise;end if;
end $$;
