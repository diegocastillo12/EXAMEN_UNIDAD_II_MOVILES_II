-- Existing independent found reports remain explicitly legacy; never infer ownership/linkage.
alter table public.found_cases add column if not exists report_kind text not null default 'legacy_found';
alter table public.found_cases add column if not exists target_lost_case_id uuid references public.lost_cases(id);
alter table public.found_cases add column if not exists target_community_case_id uuid references public.found_cases(id);
do $$ begin
 if not exists(select 1 from pg_constraint where conname='found_report_link_shape' and conrelid='public.found_cases'::regclass) then
  alter table public.found_cases add constraint found_report_link_shape check (
   (report_kind in ('legacy_found','possible_loss') and target_lost_case_id is null and target_community_case_id is null)
   or (report_kind in ('sighting','with_reporter') and num_nonnulls(target_lost_case_id,target_community_case_id)=1
       and target_community_case_id is distinct from id));
 end if;
end $$;
create index if not exists found_reports_lost_target on public.found_cases(target_lost_case_id) where deleted_at is null;
create index if not exists found_reports_community_target on public.found_cases(target_community_case_id) where deleted_at is null;

alter table public.found_case_events drop constraint if exists found_case_events_event_type_check;
alter table public.found_case_events add constraint found_case_events_event_type_check check(event_type in ('published','resolved'));

-- Public snapshots may reuse the registered pet's full type without truncation.
alter table public.found_cases drop constraint if exists found_cases_active_fields;
alter table public.found_cases add constraint found_cases_active_fields check(status in ('draft','discarded') or (
 occurred_at is not null and occurred_at>='2000-01-01'::timestamptz and latitude is not null and latitude between -85 and 85
 and longitude is not null and longitude between -180 and 180 and public_latitude is not null and public_longitude is not null
 and place_reference is not null and char_length(place_reference) between 1 and 120 and species is not null
 and (species<>'other' or (species_detail is not null and char_length(species_detail) between 1 and 60))
 and traits is not null and char_length(traits) between 1 and 200 and published_at is not null));

alter table public.found_cases drop constraint if exists found_cases_photo_count;
alter table public.found_cases add constraint found_cases_photo_count check(array_position(photo_ids,null) is null and
 (cardinality(photo_ids) between 1 and 3 or (cardinality(photo_ids)=0 and report_kind in ('sighting','with_reporter'))));
