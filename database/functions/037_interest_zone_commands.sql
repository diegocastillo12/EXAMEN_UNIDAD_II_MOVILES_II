-- UUID remains reserved after deletion so delayed create retries cannot resurrect a zone.
create or replace function public.save_interest_zone(
    p_id uuid, p_expected_version integer, p_name text,
    p_latitude double precision, p_longitude double precision, p_radius_meters integer
) returns public.interest_zones
language plpgsql security definer set search_path = '' as $$
declare
    actor uuid := auth.uid();
    current_zone public.interest_zones;
    -- Match Dart trim, including non-breaking and Unicode whitespace.
    clean_name text := btrim(p_name, E' \t\n\r\f\v' || U&'\0085\00A0\1680\2000\2001\2002\2003\2004\2005\2006\2007\2008\2009\200A\2028\2029\202F\205F\3000\FEFF');
begin
    if actor is null then raise exception 'zone_signed_out' using errcode = '42501'; end if;
    if p_id is null or p_expected_version is null or p_expected_version < 0
       or clean_name is null or char_length(clean_name) not between 1 and 60
       or p_latitude is null or p_latitude not between -85 and 85
       or p_longitude is null or p_longitude not between -180 and 180
       or p_radius_meters is null or p_radius_meters not between 100 and 50000 then
        raise exception 'zone_invalid' using errcode = '22023';
    end if;
    -- Serialize creation/update/delete on the stable key, including missing rows.
    perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_id::text, 0));
    select * into current_zone from public.interest_zones where id = p_id for update;
    if found then
        if current_zone.owner_id <> actor or current_zone.deleted_at is not null then
            raise exception 'zone_unavailable' using errcode = '42501';
        end if;
        if current_zone.version = p_expected_version + 1
           and current_zone.name = clean_name and current_zone.latitude = p_latitude
           and current_zone.longitude = p_longitude and current_zone.radius_meters = p_radius_meters then
            return current_zone;
        end if;
        if current_zone.version <> p_expected_version then
            raise exception 'zone_conflict' using errcode = '40001';
        end if;
        update public.interest_zones set name = clean_name, latitude = p_latitude,
            longitude = p_longitude, radius_meters = p_radius_meters,
            version = version + 1, updated_at = now()
            where id = p_id returning * into current_zone;
    else
        if p_expected_version <> 0 then raise exception 'zone_conflict' using errcode = '40001'; end if;
        insert into public.interest_zones (id, owner_id, name, latitude, longitude, radius_meters)
            values (p_id, actor, clean_name, p_latitude, p_longitude, p_radius_meters)
            returning * into current_zone;
    end if;
    return current_zone;
end;
$$;

create or replace function public.delete_interest_zone(p_id uuid, p_expected_version integer)
returns void language plpgsql security definer set search_path = '' as $$
declare
    actor uuid := auth.uid();
    current_zone public.interest_zones;
begin
    if actor is null then raise exception 'zone_signed_out' using errcode = '42501'; end if;
    if p_id is null or p_expected_version is null or p_expected_version < 1 then
        raise exception 'zone_invalid' using errcode = '22023';
    end if;
    perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_id::text, 0));
    select * into current_zone from public.interest_zones where id = p_id for update;
    if not found or current_zone.owner_id <> actor then
        raise exception 'zone_unavailable' using errcode = '42501';
    end if;
    if current_zone.deleted_at is not null and current_zone.version = p_expected_version + 1 then return; end if;
    if current_zone.deleted_at is not null or current_zone.version <> p_expected_version then
        raise exception 'zone_conflict' using errcode = '40001';
    end if;
    update public.interest_zones set deleted_at = now(), updated_at = now(), version = version + 1 where id = p_id;
end;
$$;
