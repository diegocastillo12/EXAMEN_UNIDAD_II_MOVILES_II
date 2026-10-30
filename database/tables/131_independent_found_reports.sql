-- Explicit user instruction25/10: independent finds coexist with linked observations.
-- Existing legacy records keep their meaning and classification.
alter table public.found_cases drop constraint if exists found_report_link_shape;
alter table public.found_cases add constraint found_report_link_shape check (
 (report_kind in ('legacy_found','possible_loss','independent_found') and target_lost_case_id is null and target_community_case_id is null)
 or (report_kind in ('sighting','with_reporter') and num_nonnulls(target_lost_case_id,target_community_case_id)=1
  and target_community_case_id is distinct from id));
