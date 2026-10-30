create or replace function public.require_platform_administrator()
returns uuid language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
begin
 perform 1 from public.platform_administrators where user_id=auth.uid() for share;
 if auth.uid() is null or not found then
  raise exception using errcode='42501',message='statistics_forbidden';
 end if;
 return auth.uid();
end $$;

-- Inclusive calendar dates in Lima. Event timestamps, never occurrence dates.
-- A recovery receipt is the only recovery evidence; never infer from resolved.
create or replace function public.read_pilot_statistics(p_from date,p_to date)
returns jsonb language plpgsql security definer set search_path=''
set lock_timeout='5s' set statement_timeout='10s' as $$
declare v_actor uuid:=public.require_platform_administrator();v_from timestamptz;v_until timestamptz;v_result jsonb;
begin
 if p_from is null or p_to is null or not isfinite(p_from) or not isfinite(p_to)
 or p_from<'2000-01-01'::date or p_to>'2099-12-31'::date or p_to<p_from or p_to-p_from>=366 then
  raise exception using errcode='23514',message='statistics_invalid';
 end if;
 v_from=p_from::timestamp at time zone 'America/Lima';
 v_until=(p_to+1)::timestamp at time zone 'America/Lima';
 -- One statement gives all aggregates the same database snapshot. Historical
 -- publications remain counted after removal/moderation; drafts never count.
 with withdrawals as (
  select 'lost'::text source,id,deleted_at from public.lost_cases where deleted_at>=v_from and deleted_at<v_until
  union all
  select 'found',id,deleted_at from public.found_cases where published_at is not null and deleted_at>=v_from and deleted_at<v_until
 ), classified as (
  select exists(select 1 from public.case_closures c where c.case_source=w.source and c.case_id=w.id and c.closed_at<=w.deleted_at) recovered
  from withdrawals w
 )
 select jsonb_build_object(
  'period',jsonb_build_object('from',to_char(p_from,'YYYY-MM-DD'),'to',to_char(p_to,'YYYY-MM-DD')),
  'timezone','America/Lima',
  'publishedLost',(select count(*) from public.lost_cases where created_at>=v_from and created_at<v_until),
  'publishedFound',(select count(*) from public.found_cases where published_at>=v_from and published_at<v_until),
  'sightings',(select count(*) from public.public_sightings where received_at>=v_from and received_at<v_until),
  'recovered',(select count(*) from public.case_closures where closed_at>=v_from and closed_at<v_until),
  'cancelled',(select count(*) from classified where not recovered),
  'archived',(select count(*) from classified where recovered),
  'reports',(select count(*) from public.content_reports where submitted_at>=v_from and submitted_at<v_until)
 ) into v_result;
 return v_result;
end $$;
