-- HU-05/HU-06. Owner-only, idempotent removal. Never delete the pet or its photos.
create or replace function public.delete_lost_case(p_id uuid)
returns void language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_owner uuid:=auth.uid(); v_pet uuid; v_case public.lost_cases%rowtype;
begin
 if v_owner is null then raise exception using errcode='42501',message='case_unauthorized'; end if;
 select pet_id into v_pet from public.lost_cases where id=p_id and owner_id=v_owner;
 if not found then raise exception using errcode='42501',message='case_unauthorized'; end if;
 -- Same lock order as publish: pet, then case. Recheck ownership under the lock.
 perform 1 from public.pets where id=v_pet for update;
 select * into v_case from public.lost_cases where id=p_id for update;
 if v_case.owner_id<>v_owner then raise exception using errcode='42501',message='case_unauthorized'; end if;
 if v_case.deleted_at is not null then return; end if;
 if v_case.status='active' then
   update public.pets set active_case_count=active_case_count-1,version=version+1,updated_at=clock_timestamp() where id=v_pet;
 end if;
 update public.lost_cases set status='resolved',deleted_at=clock_timestamp() where id=p_id;
end; $$;

create or replace function public.delete_found_case(p_id uuid)
returns void language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_owner uuid:=auth.uid(); v_case public.found_cases%rowtype;
begin
 if v_owner is null then raise exception using errcode='42501',message='found_unauthorized'; end if;
 select * into v_case from public.found_cases where id=p_id for update;
 if not found or v_case.owner_id<>v_owner then raise exception using errcode='42501',message='found_unauthorized'; end if;
 if v_case.deleted_at is not null then return; end if;
 if v_case.status not in ('active','resolved') then raise exception using errcode='40001',message='found_conflict'; end if;
 update public.found_cases set status='resolved',deleted_at=clock_timestamp() where id=p_id;
end; $$;

create or replace function public.list_my_lost_case_cards()
returns table(id uuid,owner_id uuid,pet_id uuid,status text,pet_name text,cover_path text)
language sql stable security definer set search_path='' as $$
 select c.id,c.owner_id,c.pet_id,c.status,c.pet_name,
 (select ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg'
 from public.pet_photos ph where ph.id=any(c.photo_ids) and ph.status='published' and ph.processed_at is not null
 order by ph.is_primary desc,ph.created_at,ph.id limit 1)
 from public.lost_cases c where c.owner_id=auth.uid() and c.deleted_at is null order by c.created_at desc,c.id;
$$;
create or replace function public.list_my_found_case_cards()
returns table(id uuid,owner_id uuid,status text,species text,created_at timestamptz,cover_path text)
language sql stable security definer set search_path='' as $$
 select c.id,c.owner_id,c.status,c.species,c.created_at,
 (select ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg'
 from public.found_case_photos ph where ph.id=any(c.photo_ids) and ph.status='ready' and ph.processed_at is not null
 order by ph.created_at,ph.id limit 1)
 from public.found_cases c where c.owner_id=auth.uid() and c.deleted_at is null
 and (c.status<>'discarded' or exists(select 1 from storage.objects o
 where o.bucket_id in ('found-photo-renditions','found-photo-thumbnails') and o.name like c.owner_id::text||'/'||c.id::text||'/%'))
 order by c.created_at desc,c.id;
$$;

create or replace function public.read_public_lost_case(p_id uuid)
returns table(id uuid,status text,occurred_at timestamptz,latitude double precision,longitude double precision,
    pet_name text,species text,species_detail text,size text,sex text,age_months integer,traits text,photos jsonb)
language sql stable security definer set search_path='' as $$
    select c.id,c.status,c.occurred_at,c.public_latitude,c.public_longitude,c.pet_name,c.species,c.species_detail,c.size,c.sex,c.age_months,c.traits,
        coalesce((select jsonb_agg(jsonb_build_object('id',ph.id,'path',ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg')
            order by ph.is_primary desc,ph.created_at,ph.id) from public.pet_photos ph
            where ph.id=any(c.photo_ids) and ph.status='published' and ph.processed_at is not null and ph.content_hash is not null),'[]'::jsonb)
    from public.lost_cases c where c.id=p_id and c.deleted_at is null and (c.status='active' or (c.status='resolved' and c.owner_id=auth.uid()));
$$;

create or replace function public.read_public_found_case(p_id uuid)
returns table(id uuid,status text,occurred_at timestamptz,latitude double precision,longitude double precision,
    species text,species_detail text,size text,sex text,traits text,custody text,photos jsonb)
language sql stable security definer set search_path='' as $$
    select c.id,c.status,c.occurred_at,c.public_latitude,c.public_longitude,c.species,c.species_detail,c.size,c.sex,c.traits,c.custody,
        coalesce((select jsonb_agg(jsonb_build_object('id',ph.id,'path',ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg') order by ph.created_at,ph.id)
            from public.found_case_photos ph where ph.case_id=c.id and ph.id=any(c.photo_ids) and ph.status='ready' and ph.processed_at is not null),'[]'::jsonb)
    from public.found_cases c where c.id=p_id and c.deleted_at is null and (c.status='active' or (c.status='resolved' and c.owner_id=auth.uid()));
$$;


create or replace function public.list_my_found_cases()
returns table(id uuid,owner_id uuid,status text,species text,created_at timestamptz)
language sql stable security definer set search_path='' as $$
    select c.id,c.owner_id,c.status,c.species,c.created_at from public.found_cases c
    where c.owner_id=auth.uid() and c.deleted_at is null and (c.status<>'discarded' or exists(
        select 1 from storage.objects o join public.found_case_photos ph on ph.case_id=c.id
            and o.name=ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg'
        where o.bucket_id in ('found-photo-renditions','found-photo-thumbnails')))
    order by c.created_at desc;
$$;

