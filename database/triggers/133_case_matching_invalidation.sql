create or replace function public.invalidate_case_match_embeddings()
returns trigger language plpgsql security definer set search_path='' as $$
begin
 if tg_table_name='lost_cases' then delete from public.case_match_embeddings where case_source='lost' and case_id=old.id;
 elsif tg_table_name='found_cases' then delete from public.case_match_embeddings where case_source='found' and case_id=old.id;
 elsif tg_table_name in ('pet_photos','found_case_photos') then delete from public.case_match_embeddings where photo_id=old.id;
 elsif tg_table_name='content_visibility' then delete from public.case_match_embeddings where case_source=coalesce(new.resource_kind,old.resource_kind) and case_id=coalesce(new.resource_id,old.resource_id);
 end if;
 return null;
end $$;
revoke all on function public.invalidate_case_match_embeddings() from public,anon,authenticated,service_role;
drop trigger if exists lost_case_match_invalidation on public.lost_cases;
create trigger lost_case_match_invalidation after update or delete on public.lost_cases for each row execute function public.invalidate_case_match_embeddings();
drop trigger if exists found_case_match_invalidation on public.found_cases;
create trigger found_case_match_invalidation after update or delete on public.found_cases for each row execute function public.invalidate_case_match_embeddings();
drop trigger if exists pet_photo_match_invalidation on public.pet_photos;
create trigger pet_photo_match_invalidation after update or delete on public.pet_photos for each row execute function public.invalidate_case_match_embeddings();
drop trigger if exists found_photo_match_invalidation on public.found_case_photos;
create trigger found_photo_match_invalidation after update or delete on public.found_case_photos for each row execute function public.invalidate_case_match_embeddings();
drop trigger if exists visibility_match_invalidation on public.content_visibility;
create trigger visibility_match_invalidation after insert or update or delete on public.content_visibility for each row execute function public.invalidate_case_match_embeddings();
