create or replace function public.read_recovery_pet_case(p_id uuid)
returns setof jsonb language sql stable security definer set search_path='' as $$
 select to_jsonb(r)||jsonb_build_object('can_resolve',coalesce(c.owner_id=auth.uid() and c.status='active',false))
 from public.read_public_lost_case(p_id) r join public.lost_cases c on c.id=r.id;
$$;
create or replace function public.read_recovery_report(p_id uuid)
returns setof jsonb language sql stable security definer set search_path='' as $$
 select to_jsonb(r)||jsonb_build_object('status',case when c.status='active' and c.report_kind in ('sighting','with_reporter') and not (
 exists(select 1 from public.lost_cases target where target.id=c.target_lost_case_id and target.status='active' and target.deleted_at is null)
 or exists(select 1 from public.found_cases target where target.id=c.target_community_case_id and target.report_kind='possible_loss' and target.status='active' and target.deleted_at is null))
 then 'resolved' else c.status end,'report_kind',c.report_kind,'target_id',coalesce(c.target_lost_case_id,c.target_community_case_id),
  'community_target',c.target_community_case_id is not null,
  'can_resolve',coalesce(c.owner_id=auth.uid() and c.report_kind='possible_loss' and c.status='active',false))
 from public.read_public_found_case(p_id) r join public.found_cases c on c.id=r.id
 where c.report_kind in ('legacy_found','possible_loss') or c.owner_id=auth.uid()
 or (c.target_lost_case_id is not null and exists(select 1 from public.read_public_lost_case(c.target_lost_case_id)))
 or (c.target_community_case_id is not null and exists(select 1 from public.read_public_found_case(c.target_community_case_id)));
$$;
create or replace function public.list_my_recovery_reports()
returns setof jsonb language sql stable security definer set search_path='' as $$
 select to_jsonb(r)||jsonb_build_object('status',case when c.status='active' and c.report_kind in ('sighting','with_reporter') and not (
 exists(select 1 from public.lost_cases target where target.id=c.target_lost_case_id and target.status='active' and target.deleted_at is null)
 or exists(select 1 from public.found_cases target where target.id=c.target_community_case_id and target.report_kind='possible_loss' and target.status='active' and target.deleted_at is null))
 then 'resolved' else c.status end,'report_kind',c.report_kind,'target_id',coalesce(c.target_lost_case_id,c.target_community_case_id),
  'community_target',c.target_community_case_id is not null)
 from public.list_my_found_case_cards() r join public.found_cases c on c.id=r.id;
$$;
-- Only public approximate data and processed photos, never coordinates/place/owner IDs.
create or replace function public.list_recovery_observations(p_id uuid,p_community boolean)
returns setof jsonb language sql stable security definer set search_path='' as $$
 select to_jsonb(r)||jsonb_build_object('report_kind',c.report_kind)
 from public.found_cases c cross join lateral public.read_public_found_case(c.id) r
 where c.deleted_at is null and c.status='active' and c.report_kind in ('sighting','with_reporter')
 and ((not p_community and c.target_lost_case_id=p_id and exists(select 1 from public.read_public_lost_case(p_id)))
 or (p_community and c.target_community_case_id=p_id and exists(select 1 from public.read_public_found_case(p_id))));
$$;

create or replace function public.can_read_found_photo(p_name text)
returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.found_case_photos ph join public.found_cases c on c.id=ph.case_id
 where p_name=ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg' and
 (ph.owner_id=auth.uid() or (c.status='active' and c.deleted_at is null and ph.status='ready' and ph.processed_at is not null and ph.id=any(c.photo_ids)
 and (c.report_kind in ('legacy_found','possible_loss')
 or exists(select 1 from public.lost_cases target where target.id=c.target_lost_case_id and target.deleted_at is null and (target.status='active' or target.owner_id=auth.uid()))
 or exists(select 1 from public.found_cases target where target.id=c.target_community_case_id and target.report_kind='possible_loss'
 and target.deleted_at is null and (target.status='active' or target.owner_id=auth.uid()))))));
$$;
