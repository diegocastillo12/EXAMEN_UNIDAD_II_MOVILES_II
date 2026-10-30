-- Search only the public approximate points: radius queries cannot reveal exact locations.
create index if not exists lost_cases_public_location_gist on public.lost_cases using gist
 ((extensions.st_setsrid(extensions.st_makepoint(public_longitude,public_latitude),4326)::extensions.geography))
 where deleted_at is null;
create index if not exists found_cases_public_location_gist on public.found_cases using gist
 ((extensions.st_setsrid(extensions.st_makepoint(public_longitude,public_latitude),4326)::extensions.geography))
 where deleted_at is null and status in ('active','resolved');
create index if not exists lost_cases_explore_order on public.lost_cases(created_at desc,id desc) where deleted_at is null;
create index if not exists found_cases_explore_order on public.found_cases(published_at desc,id desc) where deleted_at is null;
