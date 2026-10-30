begin;
insert into auth.users(id) values ('11111111-1111-4111-8111-111111111127'), ('22222222-2222-4222-8222-222222222227');
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111127"}', true);
do $$ declare v public.alert_preferences; t timestamptz; begin
    if exists(select owner_id from public.alert_preferences) then raise exception 'Unexpected default row'; end if;
    select * into v from public.save_alert_preferences(0,true,true,false,true,true,false);
    if v.owner_id <> auth.uid() or v.version <> 1 then raise exception 'Wrong owner/version'; end if;
    t := v.updated_at;
    select * into v from public.save_alert_preferences(0,true,true,false,true,true,false);
    if v.version <> 1 or v.updated_at <> t then raise exception 'Create retry mutated row'; end if;
    select * into v from public.save_alert_preferences(1,true,true,false,true,true,false);
    if v.version <> 1 or v.updated_at <> t then raise exception 'Unchanged write mutated row'; end if;
    select * into v from public.save_alert_preferences(1,false,true,false,true,true,false);
    if v.version <> 2 or v.enabled or not v.lost_pets or v.found_pets or not v.case_updates then raise exception 'Pause lost choices'; end if;
    t := v.updated_at;
    select * into v from public.save_alert_preferences(1,false,true,false,true,true,false);
    if v.version <> 2 or v.updated_at <> t then raise exception 'Pause retry mutated row'; end if;
    begin perform public.save_alert_preferences(1,true,true,false,true,true,false); raise exception 'Stale update accepted'; exception when serialization_failure then null; end;
    begin perform public.save_alert_preferences(0,true,true,false,true,true,false); raise exception 'Delayed creation rewrote row'; exception when serialization_failure then null; end;
    begin perform public.save_alert_preferences(2,true,false,false,false,true,false); raise exception 'No types accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_alert_preferences(2,true,true,false,false,false,false); raise exception 'No channels accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_alert_preferences(2,null,true,false,false,true,false); raise exception 'Null accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_alert_preferences(-1,false,true,false,false,true,false); raise exception 'Negative version accepted'; exception when invalid_parameter_value then null; end;
    begin perform public.save_alert_preferences(2147483647,false,true,false,false,true,false); raise exception 'Overflow version accepted'; exception when invalid_parameter_value then null; end;
    begin update public.alert_preferences set enabled = true; raise exception 'Direct update accepted'; exception when insufficient_privilege then null; end;
    begin delete from public.alert_preferences; raise exception 'Direct delete accepted'; exception when insufficient_privilege then null; end;
    begin insert into public.alert_preferences(owner_id) values(auth.uid()); raise exception 'Direct insert accepted'; exception when insufficient_privilege then null; end;
    begin perform created_at from public.alert_preferences; raise exception 'Protected column exposed'; exception when insufficient_privilege then null; end;
end; $$;
reset role;
create policy alert_preferences_test_broad on public.alert_preferences for select to authenticated using (true);
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"22222222-2222-4222-8222-222222222227"}', true);
do $$ declare v public.alert_preferences; begin
    if exists(select owner_id from public.alert_preferences) then raise exception 'Other owner read preferences'; end if;
    select * into v from public.save_alert_preferences(0,true,false,true,false,false,true);
    if v.owner_id <> auth.uid() or v.version <> 1 then raise exception 'RPC wrote another account'; end if;
end; $$;
select set_config('request.jwt.claims', '{}', true);
do $$ begin
    if exists(select owner_id from public.alert_preferences) then raise exception 'Sessionless read'; end if;
    begin perform public.save_alert_preferences(0,false,true,true,true,true,false); raise exception 'Sessionless write'; exception when insufficient_privilege then null; end;
end; $$;
set local role anon;
do $$ begin
    begin perform owner_id from public.alert_preferences; raise exception 'Anonymous read'; exception when insufficient_privilege then null; end;
    begin perform public.save_alert_preferences(0,false,true,true,true,true,false); raise exception 'Anonymous RPC'; exception when insufficient_privilege then null; end;
end; $$;
reset role;
do $$ begin
    if (select count(*) from public.alert_preferences) <> 2 then raise exception 'Duplicated preferences'; end if;
    if not exists(select 1 from public.alert_preferences where owner_id = '11111111-1111-4111-8111-111111111127' and version = 2 and not enabled and lost_pets and not found_pets and case_updates and in_app and not push) then raise exception 'A overwritten by B'; end if;
end; $$;
-- Disabled preferences may keep no selections; server constraints still guard enabled rows.
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111127"}', true);
select public.save_alert_preferences(2,false,false,false,false,false,false);
do $$ begin
    begin update public.alert_preferences set enabled = true where owner_id = auth.uid(); raise exception 'Constraint bypassed'; exception when check_violation then null; end;
end; $$;
delete from auth.users where id = '22222222-2222-4222-8222-222222222227';
do $$ begin
    if (select count(*) from public.alert_preferences) <> 1 then raise exception 'Account deletion retained preferences'; end if;
end; $$;
rollback;
