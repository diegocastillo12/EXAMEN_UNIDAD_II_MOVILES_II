-- Enforce account-to-account submissions at the write boundary, including
-- service adapters. Previously committed submissions retain their receipts.
create or replace function public.guard_blocked_recovery_notice()
returns trigger language plpgsql security definer set search_path='' as $$
declare v_owner uuid;
begin
 if new.status<>'active' or new.report_kind not in ('sighting','with_reporter') then return new;end if;
 if tg_op='UPDATE' then
  if old.status='active' and old.owner_id=new.owner_id
   and old.target_lost_case_id is not distinct from new.target_lost_case_id
   and old.target_community_case_id is not distinct from new.target_community_case_id then return new;end if;
 end if;
 if new.target_lost_case_id is not null then select owner_id into v_owner from public.lost_cases where id=new.target_lost_case_id;
 elsif new.target_community_case_id is not null then select owner_id into v_owner from public.found_cases where id=new.target_community_case_id;
 end if;
 if v_owner is not null and v_owner<>new.owner_id then
  perform public.lock_user_pair(new.owner_id,v_owner);
  if public.users_have_block(new.owner_id,v_owner) then
   raise exception using errcode='42501',message='interaction_blocked';end if;
 end if;
 return new;
end $$;
drop trigger if exists blocked_recovery_notice_guard on public.found_cases;
create trigger blocked_recovery_notice_guard before insert or update of status,owner_id,report_kind,target_lost_case_id,target_community_case_id
on public.found_cases for each row execute function public.guard_blocked_recovery_notice();

create or replace function public.guard_blocked_app_sighting()
returns trigger language plpgsql security definer set search_path='' as $$
declare v_owner uuid;
begin
 -- No account can be inferred from an anonymous QR request.
 if new.reporter_id is null then return new;end if;
 if new.case_source='lost' then select owner_id into v_owner from public.lost_cases where id=new.case_id;
 elsif new.case_source='found' then select owner_id into v_owner from public.found_cases where id=new.case_id;end if;
 if v_owner is not null and v_owner<>new.reporter_id then
  perform public.lock_user_pair(new.reporter_id,v_owner);
  if public.users_have_block(new.reporter_id,v_owner) then
   raise exception using errcode='42501',message='interaction_blocked';end if;
 end if;
 return new;
end $$;
drop trigger if exists blocked_app_sighting_guard on public.public_sightings;
create trigger blocked_app_sighting_guard before insert on public.public_sightings
for each row execute function public.guard_blocked_app_sighting();
revoke all on function public.guard_blocked_recovery_notice(),public.guard_blocked_app_sighting() from public,anon,authenticated,service_role;
