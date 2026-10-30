begin;
insert into auth.users(id) values('88888888-8888-4888-8888-888888888888'),('99999999-9999-4999-8999-999999999999');
create policy delete_test_broad on storage.objects for all to authenticated using(true) with check(true);
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"88888888-8888-4888-8888-888888888888"}',true);
select public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111111','Luna','cat',null,null,null,null,null);
select public.reserve_pet_photo('aaaaaaaa-2222-4222-8222-222222222222','aaaaaaaa-1111-4111-8111-111111111111');
insert into storage.objects(id,bucket_id,name,metadata) values('aaaaaaaa-2222-4222-8222-222222222222','pet-photos','88888888-8888-4888-8888-888888888888/aaaaaaaa-1111-4111-8111-111111111111/aaaaaaaa-2222-4222-8222-222222222222.jpg','{"mimetype":"image/jpeg","size":100}');
select public.publish_pet_photo('aaaaaaaa-2222-4222-8222-222222222222');
select set_config('request.jwt.claims','{"sub":"99999999-9999-4999-8999-999999999999"}',true);
do $$ begin
  begin perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111',1); raise exception 'B started deletion'; exception when insufficient_privilege then null; end;
  begin perform public.finish_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111'); raise exception 'B finished deletion'; exception when insufficient_privilege then null; end;
end; $$;
select set_config('request.jwt.claims','{"sub":"88888888-8888-4888-8888-888888888888"}',true);
do $$ begin
  begin perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111',2); raise exception 'Stale deletion accepted'; exception when serialization_failure then null; end;
  begin perform public.finish_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111'); raise exception 'Unconfirmed deletion accepted'; exception when insufficient_privilege then null; end;
  perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111',1);
  perform public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111',1);
  begin perform public.finish_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111'); raise exception 'Orphan file accepted'; exception when no_data_found then null; end;
  begin perform public.reserve_pet_photo('bbbbbbbb-2222-4222-8222-222222222222','aaaaaaaa-1111-4111-8111-111111111111'); raise exception 'Reserved while deleting'; exception when insufficient_privilege then null; end;
  begin perform public.publish_pet_photo('aaaaaaaa-2222-4222-8222-222222222222'); raise exception 'Published while deleting'; exception when insufficient_privilege then null; end;
  begin perform public.update_pet_v2('aaaaaaaa-1111-4111-8111-111111111111',1,'Changed','cat',null,null,null,null,null); raise exception 'Edited while deleting'; exception when insufficient_privilege then null; end;
  update storage.objects set metadata='{"mimetype":"image/jpeg","size":101}' where bucket_id='pet-photos';
  if exists(select 1 from storage.objects where metadata->>'size'='101') then raise exception 'Overwrote while deleting'; end if;
  delete from storage.objects where bucket_id='pet-photos';
  begin
    insert into storage.objects(id,bucket_id,name,metadata) values('aaaaaaaa-2222-4222-8222-222222222222','pet-photos','88888888-8888-4888-8888-888888888888/aaaaaaaa-1111-4111-8111-111111111111/aaaaaaaa-2222-4222-8222-222222222222.jpg','{}');
    raise exception 'Uploaded while deleting'; exception when insufficient_privilege then null; end;
  perform public.finish_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111');
  perform public.finish_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111');
  if public.begin_pet_deletion('aaaaaaaa-1111-4111-8111-111111111111',1) then raise exception 'Lost acknowledgement retry failed'; end if;
  if exists(select 1 from public.pets) or exists(select 1 from public.pet_photos) then raise exception 'Deletion incomplete'; end if;
  begin perform public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111111','Luna','cat',null,null,null,null,null); raise exception 'Old create resurrected deletion'; exception when serialization_failure then null; end;
  if has_table_privilege('authenticated','public.pet_deletions','select') or has_table_privilege('authenticated','public.pets','delete') then raise exception 'Direct grants leaked'; end if;
end; $$;
reset role;
do $$ begin
  if has_function_privilege('anon','public.begin_pet_deletion(uuid,integer)','execute') or has_function_privilege('anon','public.finish_pet_deletion(uuid)','execute') then raise exception 'Anon deletion grants'; end if;
end; $$;
rollback;
