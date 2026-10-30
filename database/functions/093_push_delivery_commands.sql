-- Service-only outbox. A lease prevents simultaneous workers from claiming the same job.
create or replace function public.claim_notification_delivery()
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare d public.notification_deliveries;n public.notifications;p public.alert_preferences;c record;tokens jsonb;eligible boolean;
begin
 select * into d from public.notification_deliveries where status='pending' and next_attempt_at<=clock_timestamp()
  and (leased_until is null or leased_until<clock_timestamp()) order by next_attempt_at,notification_id for update skip locked limit 1;
 if not found then return null;end if;
 select * into n from public.notifications where id=d.notification_id;
 select * into p from public.alert_preferences where owner_id=n.owner_id;
 select * into c from public.alert_case(n.case_source,n.case_id);
 eligible=found;
 if eligible then
  eligible=p.enabled and p.push and (n.kind='resolved' or c.status='active') and
   ((n.kind in ('update','resolved') and p.case_updates and (n.owner_id=c.owner_id or exists(
    select 1 from public.alert_subscriptions s where s.owner_id=n.owner_id and s.target_kind=n.case_source and s.target_id=n.case_id and s.following)))
   or (n.kind='published' and ((c.searching and p.lost_pets) or (not c.searching and p.found_pets)) and exists(
    select 1 from public.interest_zones z join public.alert_subscriptions s on s.owner_id=z.owner_id and s.target_kind='zone' and s.target_id=z.id and s.following
     where z.owner_id=n.owner_id and z.deleted_at is null and extensions.st_dwithin(
      extensions.st_setsrid(extensions.st_makepoint(z.longitude,z.latitude),4326)::extensions.geography,
      extensions.st_setsrid(extensions.st_makepoint(c.longitude,c.latitude),4326)::extensions.geography,z.radius_meters))));
 end if;
 if not coalesce(eligible,false) then
  update public.notification_deliveries set status='cancelled',last_error='no_longer_eligible',lease=null,leased_until=null where notification_id=d.notification_id;return jsonb_build_object('skipped',true);
 end if;
 select coalesce(jsonb_agg(token),'[]'::jsonb) into tokens from public.push_devices where owner_id=n.owner_id and disabled_at is null and updated_at>clock_timestamp()-interval '60 days';
 if jsonb_array_length(tokens)=0 then
  update public.notification_deliveries set next_attempt_at=clock_timestamp()+interval '1 hour',last_error='no_device' where notification_id=d.notification_id;return jsonb_build_object('skipped',true);
 end if;
 update public.notification_deliveries set lease=gen_random_uuid(),leased_until=clock_timestamp()+interval '5 minutes',attempts=attempts+1
 where notification_id=d.notification_id returning * into d;
 return jsonb_build_object('id',n.id::text,'lease',d.lease,'tokens',tokens,'title',n.title);
end $$;

create or replace function public.finish_notification_delivery(p_id bigint,p_lease uuid,p_success boolean,p_error text,p_invalid_tokens text[] default '{}')
returns void language plpgsql security definer set search_path='' as $$
declare d public.notification_deliveries;v_owner uuid;
begin
 select * into d from public.notification_deliveries where notification_id=p_id and lease=p_lease and status='pending' for update;
 if not found then raise exception using errcode='40001',message='alerts_lease_conflict';end if;
 select owner_id into v_owner from public.notifications where id=p_id;
 update public.push_devices set disabled_at=clock_timestamp() where owner_id=v_owner and token=any(p_invalid_tokens);
 update public.notification_deliveries set status=case when p_success then 'sent' else 'pending' end,
  sent_at=case when p_success then clock_timestamp() end,lease=null,leased_until=null,
  last_error=case when p_success then null else case when p_error in ('provider_unavailable','invalid_device','configuration') then p_error else 'provider_unavailable' end end,
  next_attempt_at=clock_timestamp()+make_interval(secs=>least(21600,30*power(2,least(d.attempts,9)))::integer)
 where notification_id=p_id;
end $$;
