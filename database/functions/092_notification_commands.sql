create or replace function public.read_alert_subscription(p_kind text,p_target uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare r public.alert_subscriptions;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='alerts_forbidden';end if;
 if p_kind is null or p_kind not in ('lost','found','zone') or p_target is null then raise exception using errcode='23514',message='alerts_invalid';end if;
 select * into r from public.alert_subscriptions where owner_id=auth.uid() and target_kind=p_kind and target_id=p_target;
 return jsonb_build_object('following',coalesce(r.following,false),'version',coalesce(r.version,0));
end $$;

create or replace function public.set_alert_subscription(p_command uuid,p_kind text,p_target uuid,p_following boolean,p_version integer)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare r public.alert_subscriptions;c public.alert_subscription_commands;v jsonb;visible boolean:=false;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='alerts_forbidden';end if;
 if p_command is null or p_target is null or p_kind is null or p_kind not in ('lost','found','zone') or p_following is null or p_version is null or p_version<0 or p_version>=2147483647 then raise exception using errcode='23514',message='alerts_invalid';end if;
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_command::text,12));
 select * into c from public.alert_subscription_commands where id=p_command;
 if found then
  if (c.owner_id,c.target_kind,c.target_id,c.following,c.expected_version) is distinct from (auth.uid(),p_kind,p_target,p_following,p_version) then raise exception using errcode='40001',message='alerts_conflict';end if;
  return c.receipt;
 end if;
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(auth.uid()::text||p_kind||p_target::text,12));
 select * into r from public.alert_subscriptions where owner_id=auth.uid() and target_kind=p_kind and target_id=p_target for update;
 if coalesce(r.version,0)<>p_version then raise exception using errcode='40001',message='alerts_conflict';end if;
 if p_following then
  if p_kind='zone' then
   select exists(select 1 from public.interest_zones where id=p_target and owner_id=auth.uid() and deleted_at is null) into visible;
  elsif p_kind='lost' then select exists(select 1 from public.read_recovery_pet_case(p_target) payload where payload->>'status'='active') into visible;
  else select exists(select 1 from public.read_recovery_report(p_target) payload where payload->>'status'='active') into visible;end if;
  if p_kind<>'zone' then visible=visible and exists(select 1 from public.alert_case(p_kind,p_target) where status='active');end if;
  if not visible then raise exception using errcode='42501',message='alerts_forbidden';end if;
 end if;
 insert into public.alert_subscriptions values(auth.uid(),p_kind,p_target,p_following,p_version+1)
 on conflict(owner_id,target_kind,target_id) do update set following=excluded.following,version=excluded.version;
 v=jsonb_build_object('following',p_following,'version',p_version+1);
 insert into public.alert_subscription_commands values(p_command,auth.uid(),p_kind,p_target,p_following,p_version,v);
 return v;
end $$;

create or replace function public.list_notifications(p_before bigint default null,p_limit integer default 20)
returns jsonb language plpgsql security definer set search_path='' as $$
declare items jsonb;cursor bigint;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='alerts_forbidden';end if;
 if p_limit is null or p_limit not between 1 and 50 or p_before<=0 then raise exception using errcode='23514',message='alerts_invalid';end if;
 with page as (select id::text id,case_source,case_id,kind,title,created_at,read_at,row_number() over(order by id desc) n
  from public.notifications where owner_id=auth.uid() and (p_before is null or id<p_before) order by notifications.id desc limit p_limit+1)
 select coalesce(jsonb_agg(to_jsonb(page)-'n' order by id::bigint desc) filter(where n<=p_limit),'[]'::jsonb),
 case when count(*)>p_limit then (select id::bigint from page where n=p_limit) end into items,cursor from page;
 return jsonb_build_object('items',items,'next',cursor::text);
end $$;

create or replace function public.mark_notification_read(p_id bigint)
returns void language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception using errcode='42501',message='alerts_forbidden';end if;
 update public.notifications set read_at=coalesce(read_at,clock_timestamp()) where id=p_id and owner_id=auth.uid();
 if not found then raise exception using errcode='42501',message='alerts_forbidden';end if;
end $$;

create or replace function public.register_push_device(p_token text,p_enabled boolean)
returns void language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception using errcode='42501',message='alerts_forbidden';end if;
 if p_token is null or length(p_token) not between 20 and 4096 or p_enabled is null then raise exception using errcode='23514',message='alerts_invalid';end if;
 if p_enabled then
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(auth.uid()::text,13));
  if (select count(*) from public.push_devices where owner_id=auth.uid() and disabled_at is null and token<>p_token)>=10 then
   raise exception using errcode='23514',message='alerts_device_limit';end if;
  insert into public.push_devices(token,owner_id) values(p_token,auth.uid())
  on conflict(token) do update set owner_id=excluded.owner_id,updated_at=clock_timestamp(),disabled_at=null;
 else update public.push_devices set disabled_at=clock_timestamp() where token=p_token and owner_id=auth.uid();end if;
end $$;

-- Current public case state, for routing/recipient selection. Never exposes private evidence.
create or replace function public.alert_case(p_source text,p_case uuid)
returns table(owner_id uuid,status text,latitude double precision,longitude double precision,searching boolean)
language sql stable security definer set search_path='' as $$
 select c.owner_id,c.status,c.public_latitude,c.public_longitude,true from public.lost_cases c join public.pets p on p.id=c.pet_id
 where p_source='lost' and c.id=p_case and c.deleted_at is null and p.deletion_requested_at is null
 union all
 select c.owner_id,c.status,c.public_latitude,c.public_longitude,c.report_kind='possible_loss' from public.found_cases c
 where p_source='found' and c.id=p_case and c.deleted_at is null and c.status in ('active','resolved') and c.report_kind in ('possible_loss','legacy_found')
$$;

create or replace function public.enqueue_case_notification(p_source text,p_case uuid,p_key text,p_kind text)
returns void language plpgsql security definer set search_path='' as $$
declare c record;r record;v_id bigint;v_title text;
begin
 select * into c from public.alert_case(p_source,p_case);
 if not found or (p_kind<>'resolved' and c.status<>'active') then return;end if;
 v_title=case p_kind when 'published' then 'Nuevo caso en una zona que sigues' when 'resolved' then 'Una búsqueda ha finalizado' else 'Hay novedades en un caso que sigues' end;
 for r in select p.owner_id,p.push from public.alert_preferences p where p.enabled and (p.in_app or p.push) and
  ((p_kind in ('update','resolved') and p.case_updates and (p.owner_id=c.owner_id or exists(
    select 1 from public.alert_subscriptions s where s.owner_id=p.owner_id and s.target_kind=p_source and s.target_id=p_case and s.following)))
   or (p_kind='published' and p.owner_id<>c.owner_id and ((c.searching and p.lost_pets) or (not c.searching and p.found_pets)) and exists(
    select 1 from public.interest_zones z join public.alert_subscriptions s on s.owner_id=z.owner_id and s.target_kind='zone' and s.target_id=z.id and s.following
    where z.owner_id=p.owner_id and z.deleted_at is null and extensions.st_dwithin(
      extensions.st_setsrid(extensions.st_makepoint(z.longitude,z.latitude),4326)::extensions.geography,
      extensions.st_setsrid(extensions.st_makepoint(c.longitude,c.latitude),4326)::extensions.geography,z.radius_meters))))
 loop
  insert into public.notifications(owner_id,event_key,case_source,case_id,kind,title) values(r.owner_id,p_key,p_source,p_case,p_kind,v_title)
  on conflict(owner_id,event_key) do nothing returning id into v_id;
  if v_id is not null and r.push then insert into public.notification_deliveries(notification_id) values(v_id) on conflict do nothing;end if;
 end loop;
end $$;

create or replace function public.notification_event_trigger()
returns trigger language plpgsql security definer set search_path='' as $$
declare src text;target uuid;k text;ek text;
begin
 if tg_table_name='public_sightings' then src=new.case_source;target=new.case_id;k='update';ek='sighting:'||new.id;
 elsif tg_table_name='sighting_reviews' then
  select case_source,case_id into src,target from public.public_sightings where id=new.sighting_id;k='update';ek='review:'||new.command_id;
 elsif tg_table_name='case_events' then src='lost';target=new.case_id;k=case when new.event_type='resolved' then 'resolved' else 'published' end;ek='lost:'||target||':'||new.event_type;
 else
  select case when target_lost_case_id is not null then 'lost' else 'found' end,coalesce(target_lost_case_id,target_community_case_id)
   into src,target from public.found_cases where id=new.case_id and report_kind in ('sighting','with_reporter');
  if target is not null then k='update';ek='report:'||new.case_id;
  else src='found';target=new.case_id;k=case when new.event_type='resolved' then 'resolved' else 'published' end;ek='found:'||target||':'||new.event_type;end if;
 end if;
 perform public.enqueue_case_notification(src,target,ek,k);return new;
end $$;
