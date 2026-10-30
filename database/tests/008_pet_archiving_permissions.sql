begin;
insert into auth.users(id) values('88888888-8888-4888-8888-888888888888'),('99999999-9999-4999-8999-999999999999');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"88888888-8888-4888-8888-888888888888"}',true);
select public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111111','Luna','cat',null,null,null,null,null);
select public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111112','Con historial','dog',null,null,null,null,null);
select public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111113','Caso activo','dog',null,null,null,null,null);
select public.reserve_pet_photo('aaaaaaaa-2222-4222-8222-222222222222','aaaaaaaa-1111-4111-8111-111111111111');
insert into storage.objects(id,bucket_id,name,metadata) values('aaaaaaaa-2222-4222-8222-222222222222','pet-photos','88888888-8888-4888-8888-888888888888/aaaaaaaa-1111-4111-8111-111111111111/aaaaaaaa-2222-4222-8222-222222222222.jpg','{"mimetype":"image/jpeg","size":100}');
select public.publish_pet_photo('aaaaaaaa-2222-4222-8222-222222222222');
reset role;
-- Simulate the SERVER transaction that a future case command must perform.
update public.pets set case_history_at=now() where id='aaaaaaaa-1111-4111-8111-111111111112';
update public.pets set case_history_at=now(),active_case_count=1 where id='aaaaaaaa-1111-4111-8111-111111111113';
do $$ begin
  begin update public.pets set case_history_at=null where id='aaaaaaaa-1111-4111-8111-111111111112'; raise exception 'History erased'; exception when check_violation then null; end;
  begin update public.pets set archived_at=now() where id='aaaaaaaa-1111-4111-8111-111111111113'; raise exception 'Archived active case'; exception when check_violation then null; end;
  begin delete from public.pets where id='aaaaaaaa-1111-4111-8111-111111111112'; raise exception 'Direct server delete lost history'; exception when check_violation then null; end;
end; $$;
set local role anon;
select set_config('request.jwt.claims','{}',true);
do $$ begin
  begin perform public.archive_pet('aaaaaaaa-1111-4111-8111-111111111111',1); raise exception 'Anon archive'; exception when insufficient_privilege then null; end;
  begin perform public.restore_pet('aaaaaaaa-1111-4111-8111-111111111111',1); raise exception 'Anon restore'; exception when insufficient_privilege then null; end;
  begin perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111',1); raise exception 'Anon delete'; exception when insufficient_privilege then null; end;
end; $$;
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"99999999-9999-4999-8999-999999999999"}',true);
do $$ begin
  begin perform public.archive_pet('aaaaaaaa-1111-4111-8111-111111111111',1); raise exception 'Other owner archive'; exception when insufficient_privilege then null; end;
  begin perform public.restore_pet('aaaaaaaa-1111-4111-8111-111111111111',1); raise exception 'Other owner restore'; exception when insufficient_privilege then null; end;
  begin perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111',1); raise exception 'Other owner delete'; exception when insufficient_privilege then null; end;
  if exists(select 1 from public.pets) then raise exception 'Owner RLS leaked'; end if;
end; $$;
select set_config('request.jwt.claims','{"sub":"88888888-8888-4888-8888-888888888888"}',true);
do $$ declare v public.pets; t timestamptz; begin
  if has_table_privilege('authenticated','public.pets','update') or has_column_privilege('authenticated','public.pets','case_history_at','update') then raise exception 'Client can edit guards'; end if;
  begin update public.pets set archived_at=now(); raise exception 'Direct archive'; exception when insufficient_privilege then null; end;
  begin perform public.archive_pet('aaaaaaaa-1111-4111-8111-111111111111',null); raise exception 'Null version accepted'; exception when serialization_failure then null; end;
  select * into v from public.archive_pet('aaaaaaaa-1111-4111-8111-111111111111',1);
  t:=v.archived_at;
  if t is null or v.version<>2 then raise exception 'Archive failed'; end if;
  select * into v from public.archive_pet(v.id,1);
  if v.version<>2 or v.archived_at<>t then raise exception 'Archive retry wrote twice'; end if;
  if not exists(select 1 from public.pet_photos) or not exists(select 1 from storage.objects where bucket_id='pet-photos') then raise exception 'Archive removed photos'; end if;
  if (select count(*) from public.pets where archived_at is null)<>2 then raise exception 'Active filter failed'; end if;
  select * into v from public.restore_pet(v.id,2);
  if v.archived_at is not null or v.version<>3 then raise exception 'Restore failed'; end if;
  select * into v from public.restore_pet(v.id,2);
  if v.version<>3 then raise exception 'Restore retry wrote twice'; end if;
  begin perform public.archive_pet(v.id,1); raise exception 'Stale archive accepted'; exception when serialization_failure then null; end;
  begin perform public.archive_pet('aaaaaaaa-1111-4111-8111-111111111113',1); raise exception 'Archived active case'; exception when check_violation then null; end;
  begin perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111112',1); raise exception 'Deleted closed-case history'; exception when check_violation then null; end;
  begin perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111113',1); raise exception 'Deleted active case'; exception when check_violation then null; end;
  select * into v from public.archive_pet('aaaaaaaa-1111-4111-8111-111111111112',1);
  if v.archived_at is null or v.case_history_at is null then raise exception 'History archive failed'; end if;
  select * into v from public.restore_pet(v.id,2);
  if v.archived_at is not null or v.case_history_at is null then raise exception 'Restore erased history'; end if;
  perform public.archive_pet('aaaaaaaa-1111-4111-8111-111111111111',3);
  perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111',4);
  begin perform public.restore_pet('aaaaaaaa-1111-4111-8111-111111111111',4); raise exception 'Restored pending deletion'; exception when insufficient_privilege then null; end;
  begin perform public.archive_pet('aaaaaaaa-1111-4111-8111-111111111111',4); raise exception 'Archived pending deletion'; exception when insufficient_privilege then null; end;
  begin perform public.finish_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111'); raise exception 'Deleted before file cleanup'; exception when no_data_found then null; end;
end; $$;
reset role;
do $$ begin
  begin update public.pets set case_history_at=now() where id='aaaaaaaa-1111-4111-8111-111111111111'; raise exception 'Case added while deleting'; exception when insufficient_privilege then null; end;
end; $$;
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"88888888-8888-4888-8888-888888888888"}',true);
delete from storage.objects where bucket_id='pet-photos';
select public.finish_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111');
select public.finish_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111');
do $$ begin
  if public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111',4) then raise exception 'Delete retry not idempotent'; end if;
  if exists(select 1 from public.pet_photos) then raise exception 'Orphan photos'; end if;
  if not exists(select 1 from public.pets where case_history_at is not null) then raise exception 'History lost'; end if;
end; $$;
reset role;
update public.pets set active_case_count=0 where id='aaaaaaaa-1111-4111-8111-111111111113';
set local role authenticated;
select public.archive_pet('aaaaaaaa-1111-4111-8111-111111111113',1);
do $$ begin
  begin perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111113',2); raise exception 'Case closure enabled hard deletion'; exception when check_violation then null; end;
end; $$;
reset role;
rollback;
