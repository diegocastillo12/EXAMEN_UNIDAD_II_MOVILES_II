create or replace function public.publish_lost_case(
    p_id uuid,p_pet_id uuid,p_pet_version integer,p_occurred_at timestamptz,
    p_latitude double precision,p_longitude double precision,p_place_reference text,p_photo_ids uuid[])
returns setof public.lost_cases language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_pet public.pets; v_case public.lost_cases; v_photos uuid[];
begin
    if v_owner is null then raise exception using errcode='42501',message='case_unauthorized'; end if;
    if p_id is null or p_pet_id is null then raise exception using errcode='23514',message='case_invalid'; end if;
    -- Lock order shared with photo processing/archive/delete: pet first.
    select * into v_pet from public.pets where id=p_pet_id for update;
    if not found or v_pet.owner_id<>v_owner then raise exception using errcode='42501',message='case_unauthorized'; end if;
    -- Normalize selection order: it has no business meaning.
    select array_agg(id order by id) into v_photos from (select distinct unnest(p_photo_ids) id) selected;
    select * into v_case from public.lost_cases where id=p_id;
    if found then
        if v_case.owner_id<>v_owner or v_case.pet_id<>p_pet_id then raise exception using errcode='42501',message='case_unauthorized'; end if;
        if v_case.pet_version=p_pet_version and v_case.occurred_at=p_occurred_at
            and v_case.latitude=p_latitude and v_case.longitude=p_longitude
            and v_case.place_reference=public.pet_trim(p_place_reference) and v_case.photo_ids=v_photos then
            return next v_case; return;
        end if;
        raise exception using errcode='40001',message='case_conflict';
    end if;
    if v_pet.archived_at is not null or v_pet.deletion_requested_at is not null then raise exception using errcode='23514',message='case_pet_unavailable'; end if;
    if exists(select 1 from public.lost_cases where pet_id=p_pet_id and status='active') then raise exception using errcode='23505',message='case_already_active'; end if;
    if p_pet_version is null or p_pet_version<>v_pet.version then raise exception using errcode='40001',message='case_conflict'; end if;
    if p_occurred_at is null or p_occurred_at>clock_timestamp() or p_occurred_at<'2000-01-01'::timestamptz
        or p_latitude is null or not(p_latitude between -85 and 85)
        or p_longitude is null or not(p_longitude between -180 and 180)
        or p_place_reference is null or char_length(public.pet_trim(p_place_reference)) not between 1 and 120
        or p_photo_ids is null or cardinality(p_photo_ids) not between 1 and 3
        or cardinality(v_photos)<>cardinality(p_photo_ids) or array_position(p_photo_ids,null) is not null then
        raise exception using errcode='23514',message='case_invalid';
    end if;
    perform public.validate_pet_fields(v_pet.name,v_pet.species,v_pet.sex,v_pet.age_months,v_pet.traits);
    if v_pet.size is null or v_pet.age_months is null or v_pet.traits is null
        or char_length(v_pet.traits) not between 1 and 200
        or (v_pet.species='other' and v_pet.species_detail is null) then
        raise exception using errcode='23514',message='case_pet_incomplete';
    end if;
    -- Historic unprocessed photos never become public by publication of a case.
    if (select count(*) from public.pet_photos ph where ph.id=any(v_photos) and ph.pet_id=p_pet_id
        and ph.owner_id=v_owner and ph.status='published' and ph.processed_at is not null
        and ph.content_hash is not null)<>cardinality(v_photos) then
        raise exception using errcode='23514',message='case_photos_unverified';
    end if;
    insert into public.lost_cases(id,owner_id,pet_id,pet_version,occurred_at,latitude,longitude,place_reference,
        public_latitude,public_longitude,pet_name,species,species_detail,size,sex,age_months,traits,photo_ids)
    values(p_id,v_owner,p_pet_id,p_pet_version,p_occurred_at,p_latitude,p_longitude,public.pet_trim(p_place_reference),
        floor(p_latitude*100)/100+0.005,least(179.995,floor(p_longitude*100)/100+0.005),
        v_pet.name,v_pet.species,v_pet.species_detail,v_pet.size,v_pet.sex,v_pet.age_months,v_pet.traits,v_photos)
    returning * into v_case;
    update public.pets set case_history_at=coalesce(case_history_at,v_case.created_at),active_case_count=active_case_count+1,
        version=version+1,updated_at=v_case.created_at where id=p_pet_id;
    insert into public.case_events(case_id,actor_id,event_type) values(p_id,v_owner,'published');
    return next v_case;
end; $$;

-- Metadata of processed bytes is projected, never originals/profile/private location.
create or replace function public.read_public_lost_case(p_id uuid)
returns table(id uuid,status text,occurred_at timestamptz,latitude double precision,longitude double precision,
    pet_name text,species text,species_detail text,size text,sex text,age_months integer,traits text,photos jsonb)
language sql stable security definer set search_path='' as $$
    select c.id,c.status,c.occurred_at,c.public_latitude,c.public_longitude,c.pet_name,c.species,c.species_detail,c.size,c.sex,c.age_months,c.traits,
        coalesce((select jsonb_agg(jsonb_build_object('id',ph.id,'path',ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg')
            order by ph.is_primary desc,ph.created_at,ph.id) from public.pet_photos ph
            where ph.id=any(c.photo_ids) and ph.status='published' and ph.processed_at is not null and ph.content_hash is not null),'[]'::jsonb)
    from public.lost_cases c where c.id=p_id and c.status='active';
$$;

create or replace function public.is_public_case_rendition(p_name text)
returns boolean language sql stable security definer set search_path='' as $$
    select exists(select 1 from public.lost_cases c join public.pet_photos ph on ph.id=any(c.photo_ids) and ph.pet_id=c.pet_id
        where c.status='active' and ph.status='published' and ph.processed_at is not null and ph.content_hash is not null
        and p_name=ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg');
$$;
