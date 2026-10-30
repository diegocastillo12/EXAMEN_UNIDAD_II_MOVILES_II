begin;
insert into auth.users(id) values ('11111111-1111-4111-8111-111111111126'), ('22222222-2222-4222-8222-222222222226');
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111126"}', true);
do $$ declare v public.interest_zones; t timestamptz; begin
    select * into v from public.save_interest_zone('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa26', 0, ' Casa ', -12.04, -77.04, 1000);
    t := v.updated_at;
    select * into v from public.save_interest_zone(v.id, 0, 'Casa', -12.04, -77.04, 1000);
    if v.version <> 1 or v.updated_at <> t then raise exception 'Create retry mutated zone'; end if;
    select * into v from public.save_interest_zone(v.id, 1, 'Parque', -12.05, -77.03, 500);
    if v.version <> 2 then raise exception 'Update did not advance version'; end if;
    t := v.updated_at;
    select * into v from public.save_interest_zone(v.id, 1, 'Parque', -12.05, -77.03, 500);
    if v.version <> 2 or v.updated_at <> t then raise exception 'Update retry mutated zone'; end if;
    begin perform public.save_interest_zone(v.id, 1, 'Stale', -12.05, -77.03, 500); raise exception 'Stale update accepted'; exception when serialization_failure then null; end;
    begin perform public.save_interest_zone(v.id, 2, ' ', -12, -77, 500); raise exception 'Blank name accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_interest_zone(v.id, 2, U&'\00A0\FEFF', -12, -77, 500); raise exception 'Unicode blank name accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_interest_zone(v.id, 2, repeat('🐾',61), -12, -77, 500); raise exception 'Long name accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_interest_zone(v.id, 2, 'Zone', 86, -77, 500); raise exception 'Invalid latitude accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_interest_zone(v.id, 2, 'Zone', -12, 181, 500); raise exception 'Invalid longitude accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_interest_zone(v.id, 2, 'Zone', 'NaN'::float8, -77, 500); raise exception 'NaN accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_interest_zone(v.id, 2, 'Zone', -12, -77, 99); raise exception 'Small radius accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_interest_zone(v.id, 2, 'Zone', -12, -77, 50001); raise exception 'Large radius accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.delete_interest_zone(v.id, 1); raise exception 'Stale delete accepted'; exception when serialization_failure then null; end;
    begin update public.interest_zones set name = 'Bypass'; raise exception 'Direct write accepted'; exception when insufficient_privilege then null; end;
    begin delete from public.interest_zones; raise exception 'Direct delete accepted'; exception when insufficient_privilege then null; end;
    begin insert into public.interest_zones(id,owner_id,name,latitude,longitude,radius_meters) values(gen_random_uuid(),auth.uid(),'Bypass',0,0,1000); raise exception 'Direct insert accepted'; exception when insufficient_privilege then null; end;
end; $$;
reset role;
-- A broad permissive policy must not defeat the restrictive ownership guard.
create policy interest_zones_test_broad on public.interest_zones for select to authenticated using (true);
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"22222222-2222-4222-8222-222222222226"}', true);
do $$ begin
    if exists(select id from public.interest_zones) then raise exception 'Other owner read zone'; end if;
    begin perform public.save_interest_zone('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa26', 2, 'Hijack', 0, 0, 1000); raise exception 'Other owner updated zone'; exception when insufficient_privilege then null; end;
    begin perform public.delete_interest_zone('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa26', 2); raise exception 'Other owner deleted zone'; exception when insufficient_privilege then null; end;
end; $$;
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111126"}', true);
select public.delete_interest_zone('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa26', 2);
select public.delete_interest_zone('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa26', 2);
do $$ begin
    if exists(select id from public.interest_zones) then raise exception 'Deleted zone visible'; end if;
    begin perform public.save_interest_zone('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa26', 0, 'Casa', -12.04, -77.04, 1000); raise exception 'Late create resurrected deleted zone'; exception when insufficient_privilege then null; end;
end; $$;
set local role anon;
select set_config('request.jwt.claims', '{}', true);
do $$ begin
    begin perform id from public.interest_zones; raise exception 'Anonymous read'; exception when insufficient_privilege then null; end;
    begin perform public.save_interest_zone(gen_random_uuid(), 0, 'Zone', 0, 0, 1000); raise exception 'Anonymous create'; exception when insufficient_privilege then null; end;
    begin perform public.delete_interest_zone('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa26', 2); raise exception 'Anonymous delete'; exception when insufficient_privilege then null; end;
end; $$;
reset role;
do $$ begin
    if (select count(*) from public.interest_zones) <> 1 or (select version from public.interest_zones) <> 3 then raise exception 'Retry lost tombstone'; end if;
end; $$;
rollback;
