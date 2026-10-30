begin;
create policy gallery_test_broad on storage.objects for all to authenticated,anon using(true) with check(true);
insert into auth.users(id) values
 ('88888888-8888-4888-8888-888888888888'),
 ('99999999-9999-4999-8999-999999999999');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"88888888-8888-4888-8888-888888888888"}',true);
do $$ declare p public.pets; ph public.pet_photos; begin
  if has_function_privilege('authenticated','public.create_pet(uuid,text,text,text,integer,text)','execute') then raise exception 'Legacy validation bypass remains'; end if;
  begin
    perform public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111111','Luna','other',null,null,null,null,null);
    raise exception 'Other type required';
  exception when check_violation then null; end;
  begin
    perform public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111111','Luna','dog',null,null,null,null,'huge');
    raise exception 'Invalid size accepted';
  exception when check_violation then null; end;
  select * into p from public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111111','Luna','other',null,null,null,' Conejo ','medium');
  if p.species_detail<>'Conejo' or p.size<>'medium' then raise exception 'Details not normalized'; end if;
  select * into ph from public.reserve_pet_photo('aaaaaaaa-2222-4222-8222-222222222222',p.id);
  perform public.reserve_pet_photo(ph.id,p.id);
  if (select count(*) from public.pet_photos)<>1 then raise exception 'Duplicate reservation'; end if;
  begin perform public.publish_pet_photo(ph.id); raise exception 'Published without file';
  exception when no_data_found then null; end;
  insert into storage.objects(id,bucket_id,name,metadata) values(ph.id,'pet-photos',auth.uid()::text||'/'||p.id::text||'/'||ph.id::text||'.jpg','{"mimetype":"image/jpeg","size":100}');
  perform public.publish_pet_photo(ph.id);
  perform public.publish_pet_photo(ph.id);
  if (select status from public.pet_photos where id=ph.id)<>'published' then raise exception 'Photo not confirmed'; end if;
  begin perform public.remove_pet_photo(ph.id); raise exception 'Orphan file accepted';
  exception when no_data_found then null; end;
  perform public.reserve_pet_photo('bbbbbbbb-2222-4222-8222-222222222222',p.id);
  perform public.reserve_pet_photo('cccccccc-2222-4222-8222-222222222222',p.id);
  begin perform public.reserve_pet_photo('dddddddd-2222-4222-8222-222222222222',p.id); raise exception 'Fourth photo accepted';
  exception when check_violation then null; end;
  begin
    insert into storage.objects(id,bucket_id,name,metadata) values('dddddddd-2222-4222-8222-222222222222','pet-photos',auth.uid()::text||'/'||p.id::text||'/unreserved.jpg','{}');
    raise exception 'Unreserved upload accepted';
  exception when insufficient_privilege then null; end;
  begin delete from public.pet_photos; raise exception 'Direct metadata deletion accepted';
  exception when insufficient_privilege then null; end;
end; $$;
select set_config('request.jwt.claims','{"sub":"99999999-9999-4999-8999-999999999999"}',true);
do $$ begin
  if exists(select 1 from public.pet_photos) or exists(select 1 from storage.objects where bucket_id='pet-photos') then raise exception 'Cross account photo read'; end if;
  begin perform public.reserve_pet_photo('dddddddd-2222-4222-8222-222222222222','aaaaaaaa-1111-4111-8111-111111111111'); raise exception 'B uploaded to A';
  exception when insufficient_privilege then null; end;
  begin perform public.publish_pet_photo('aaaaaaaa-2222-4222-8222-222222222222'); raise exception 'B published A photo';
  exception when insufficient_privilege then null; end;
  delete from storage.objects where bucket_id='pet-photos';
  perform public.remove_pet_photo('aaaaaaaa-2222-4222-8222-222222222222');
end; $$;
select set_config('request.jwt.claims','{"sub":"88888888-8888-4888-8888-888888888888"}',true);
do $$ begin
  if (select count(*) from public.pet_photos)<>3 or (select count(*) from storage.objects where bucket_id='pet-photos')<>1 then raise exception 'B deleted A photo'; end if;
  delete from storage.objects where bucket_id='pet-photos';
  perform public.remove_pet_photo('aaaaaaaa-2222-4222-8222-222222222222');
  perform public.remove_pet_photo('aaaaaaaa-2222-4222-8222-222222222222');
  if (select count(*) from public.pet_photos)<>2 then raise exception 'Deletion retry failed'; end if;
end; $$;
reset role;
do $$ begin
  if (select public from storage.buckets where id='pet-photos') then raise exception 'Public gallery'; end if;
  if has_table_privilege('anon','public.pet_photos','select') or has_function_privilege('anon','public.reserve_pet_photo(uuid,uuid)','execute') then raise exception 'Anon photo grants'; end if;
end; $$;
rollback;
