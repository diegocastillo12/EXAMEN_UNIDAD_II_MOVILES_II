create or replace function public.lock_user_pair(p_first uuid,p_second uuid)
returns void language sql security definer set search_path='' as $$
 select pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(
 least(p_first::text,p_second::text)||':'||greatest(p_first::text,p_second::text),142));
$$;

create or replace function public.users_have_block(p_first uuid,p_second uuid)
returns boolean language sql stable security definer set search_path='' as $$
 select p_first is not null and p_second is not null and exists(
  select 1 from public.user_blocks where enabled and
  ((owner_id=p_first and blocked_id=p_second) or (owner_id=p_second and blocked_id=p_first)));
$$;

-- The returned identifier belongs to a private relationship, never to a profile.
create or replace function public.user_block_json(p_row public.user_blocks)
returns jsonb language sql immutable set search_path='' as $$
 select jsonb_build_object('id',p_row.id,'label',p_row.label,'enabled',p_row.enabled,'version',p_row.version);
$$;

create or replace function public.prepare_user_block(p_kind text,p_resource uuid)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' set statement_timeout='10s' as $$
declare v_target uuid;v_label text;v_row public.user_blocks;v_sighting public.public_sightings;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='block_forbidden';end if;
 if p_resource is null or p_kind is null or p_kind not in ('lost','found','sighting') then
  raise exception using errcode='23514',message='block_invalid';end if;
 if p_kind='lost' then
  if not exists(select 1 from public.read_recovery_pet_case(p_resource)) then
   raise exception using errcode='42501',message='block_forbidden';end if;
  select owner_id,'Reportante de '||pet_name into v_target,v_label from public.lost_cases where id=p_resource;
 elsif p_kind='found' then
  if not exists(select 1 from public.read_recovery_report(p_resource)) then
   raise exception using errcode='42501',message='block_forbidden';end if;
  select owner_id,'Reportante del aviso' into v_target,v_label from public.found_cases where id=p_resource;
 else
  select * into v_sighting from public.public_sightings where id=p_resource;
  if not found or public.is_moderation_hidden('sighting',p_resource) then
   raise exception using errcode='42501',message='block_forbidden';end if;
  perform public.authorized_timeline_case(v_sighting.case_source,v_sighting.case_id);
  v_target:=v_sighting.reporter_id;v_label:='Reportante del avistamiento';
 end if;
 -- Anonymous QR reporters cannot be identified as accounts; own content has no action.
 if v_target is null or v_target=auth.uid() then return null;end if;
 perform public.lock_user_pair(auth.uid(),v_target);
 insert into public.user_blocks(owner_id,blocked_id,label)
 values(auth.uid(),v_target,left(v_label,120)) on conflict(owner_id,blocked_id) do nothing;
 select * into v_row from public.user_blocks where owner_id=auth.uid() and blocked_id=v_target;
 return public.user_block_json(v_row);
end $$;

create or replace function public.list_user_blocks(p_before uuid default null)
returns jsonb language plpgsql stable security definer set search_path='' set statement_timeout='5s' as $$
declare v_items jsonb;v_next uuid;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='block_forbidden';end if;
 select coalesce(jsonb_agg(public.user_block_json(b) order by b.id desc),'[]'::jsonb)
 into v_items from (select * from public.user_blocks where owner_id=auth.uid() and enabled
 and (p_before is null or id<p_before) order by id desc limit 20) b;
 if jsonb_array_length(v_items)=20 then
  v_next:=(v_items->19->>'id')::uuid;
  if not exists(select 1 from public.user_blocks where owner_id=auth.uid() and enabled and id<v_next) then v_next:=null;end if;
 end if;
 return jsonb_build_object('items',v_items,'next',v_next);
end $$;

create or replace function public.set_user_block(p_id uuid,p_enabled boolean,p_version bigint)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' set statement_timeout='10s' as $$
declare v_row public.user_blocks;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='block_forbidden';end if;
 if p_id is null or p_enabled is null or p_version is null or p_version not between 0 and 2147483646 then
  raise exception using errcode='23514',message='block_invalid';end if;
 select * into v_row from public.user_blocks where id=p_id and owner_id=auth.uid();
 if not found then raise exception using errcode='42501',message='block_forbidden';end if;
 perform public.lock_user_pair(auth.uid(),v_row.blocked_id);
 select * into v_row from public.user_blocks where id=p_id and owner_id=auth.uid() for update;
 -- Exact retries succeed; an intervening opposite choice is never overwritten.
 if v_row.version=p_version+1 and v_row.enabled=p_enabled then return public.user_block_json(v_row);end if;
 if v_row.version<>p_version then raise exception using errcode='40001',message='block_conflict';end if;
 if v_row.enabled<>p_enabled then
  update public.user_blocks set enabled=p_enabled,version=version+1,updated_at=clock_timestamp()
  where id=p_id returning * into v_row;
 end if;
 return public.user_block_json(v_row);
end $$;
