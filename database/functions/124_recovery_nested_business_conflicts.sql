-- HU-15.2 / RF-32. publish_recovery_report delegates field/photo attestation
-- and replay comparison to this internal function. Complete plan037 without
-- rewriting its applied migration or changing the helper's privileges/settings.
do $nested_recovery_business_conflicts$
declare
 v_function regprocedure;
 v_definition text;
 v_updated text;
begin
 v_function:=pg_catalog.to_regprocedure(
  'public.publish_found_case(uuid,timestamp with time zone,double precision,double precision,text,text,text,text,text,text,text,uuid[])');
 if v_function is null then raise exception 'Missing required publish_found_case helper'; end if;
 select pg_catalog.pg_get_functiondef(v_function::oid) into v_definition;
 v_updated:=pg_catalog.regexp_replace(v_definition,
  'errcode\s*=\s*''40001''','errcode=''PT409''','gi');
 if v_updated<>v_definition then
  execute v_updated;
 elsif pg_catalog.strpos(v_definition,'PT409')=0 then
  raise exception 'Unexpected publish_found_case helper conflict contract';
 end if;
end;
$nested_recovery_business_conflicts$;
