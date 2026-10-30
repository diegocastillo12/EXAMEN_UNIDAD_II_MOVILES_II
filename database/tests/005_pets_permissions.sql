-- Development fixtures; rollback all rows. Tests actual PostgreSQL roles and RPCs.
begin;
insert into auth.users(id,aud,role,email,raw_user_meta_data) values
 ('88888888-8888-4888-8888-888888888888','authenticated','authenticated','pet-a@tests.invalid','{}'),
 ('99999999-9999-4999-8999-999999999999','authenticated','authenticated','pet-b@tests.invalid','{}');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"88888888-8888-4888-8888-888888888888","role":"authenticated"}',true);
do $$
declare first_pet public.pets; updated_pet public.pets; retried_pet public.pets;
begin
  select * into first_pet from public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111111',U&'\00A0Luna\00A0','dog',null,null,'  ',null,null);
  if first_pet.name <> 'Luna' or first_pet.sex is not null or first_pet.age_months is not null or first_pet.traits is not null or first_pet.owner_id <> auth.uid() then raise exception 'Pet normalization/ownership failed'; end if;
  perform public.create_pet_v2(first_pet.id,'Luna','dog',null,null,null,null,null);
  if (select count(*) from public.pets) <> 1 then raise exception 'Create retry duplicated pet'; end if;
  begin
    perform public.create_pet_v2(first_pet.id,'Changed payload','dog',null,null,null,null,null);
    raise exception 'Create retry silently overwrote payload';
  exception when serialization_failure then null; end;
  begin
    perform public.create_pet_v2('bbbbbbbb-1111-4111-8111-111111111111',' ','dog',null,null,null,null,null);
    raise exception 'Empty pet name accepted';
  exception when check_violation then null; end;
  begin
    perform public.create_pet_v2('bbbbbbbb-1111-4111-8111-111111111111','Luna',null,null,null,null,null,null);
    raise exception 'Missing species accepted';
  exception when check_violation then null; end;
  begin
    perform public.create_pet_v2('bbbbbbbb-1111-4111-8111-111111111111','Luna','dog',null,601,null,null,null);
    raise exception 'Invalid age accepted';
  exception when check_violation then null; end;
  begin
    perform public.create_pet_v2('bbbbbbbb-1111-4111-8111-111111111111','Luna','dog',null,null,repeat('x',501),null,null);
    raise exception 'Overlong traits accepted';
  exception when check_violation then null; end;
  select * into updated_pet from public.update_pet_v2(first_pet.id,1,repeat('🐾',80),'cat','female',0,'  Negra  ',null,null);
  if updated_pet.version <> 2 or updated_pet.traits <> 'Negra' or char_length(updated_pet.name) <> 80 then raise exception 'Update normalization/version failed'; end if;
  select * into retried_pet from public.update_pet_v2(first_pet.id,1,repeat('🐾',80),'cat','female',0,'Negra',null,null);
  if retried_pet.updated_at <> updated_pet.updated_at or retried_pet.version <> 2 then raise exception 'Retry changed version/timestamp'; end if;
  begin
    perform public.update_pet_v2(first_pet.id,1,'Stale edit','dog',null,null,null,null,null);
    raise exception 'Stale update overwrote pet';
  exception when serialization_failure then null; end;
  begin
    update public.pets set owner_id='99999999-9999-4999-8999-999999999999';
    raise exception 'Direct owner change accepted';
  exception when insufficient_privilege then null; end;
  begin
    insert into public.pets(id,owner_id,name,species) values('bbbbbbbb-1111-4111-8111-111111111111',auth.uid(),'Direct','dog');
    raise exception 'Direct insertion bypassed RPC';
  exception when insufficient_privilege then null; end;
  begin
    delete from public.pets;
    raise exception 'Client deleted pets';
  exception when insufficient_privilege then null; end;
end;
$$;
select set_config('request.jwt.claims','{"sub":"99999999-9999-4999-8999-999999999999","role":"authenticated"}',true);
do $$
begin
  if exists(select 1 from public.pets) then raise exception 'B read A pets'; end if;
  begin
    perform public.create_pet_v2('aaaaaaaa-1111-4111-8111-111111111111','Luna','dog',null,null,null,null,null);
    raise exception 'B claimed A pet id';
  exception when insufficient_privilege then null; end;
  begin
    perform public.update_pet_v2('aaaaaaaa-1111-4111-8111-111111111111',2,'Hijack','dog',null,null,null,null,null);
    raise exception 'B updated A pet';
  exception when no_data_found then null; end;
  perform public.create_pet_v2('bbbbbbbb-1111-4111-8111-111111111111','Milo','other',null,null,null,'Conejo',null);
  if (select count(*) from public.pets) <> 1 then raise exception 'B own pet missing'; end if;
end;
$$;
select set_config('request.jwt.claims','{}',true);
do $$ begin
  begin
    perform public.create_pet_v2('cccccccc-1111-4111-8111-111111111111','No auth','cat',null,null,null,null,null);
    raise exception 'Missing identity accepted';
  exception when insufficient_privilege then null; end;
end; $$;
reset role;
set local role anon;
do $$ begin
  if has_table_privilege('anon','public.pets','select') or has_function_privilege('anon','public.create_pet_v2(uuid,text,text,text,integer,text,text,text)','execute') then raise exception 'Anonymous pets grants leaked'; end if;
end; $$;
reset role;
rollback;
