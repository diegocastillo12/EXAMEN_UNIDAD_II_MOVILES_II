-- HU-15.2 / RF-32: deterministic business conflicts must not trigger a
-- PostgREST serialization retry loop. Preserve bodies, settings and privileges.
-- Only these three queue RPCs are in scope; this is not a global SQLSTATE migration.
do $recovery_business_conflicts$
declare
 v_signature text;
 v_function regprocedure;
 v_definition text;
 v_updated text;
begin
 foreach v_signature in array array[
  'public.publish_lost_case(uuid,uuid,integer,timestamp with time zone,double precision,double precision,text,uuid[])',
  'public.prepare_recovery_report(uuid,uuid[],text,uuid,boolean)',
  'public.publish_recovery_report(uuid,text,uuid,boolean,timestamp with time zone,double precision,double precision,text,text,text,text,text,text,text,uuid[])'
 ] loop
  v_function:=pg_catalog.to_regprocedure(v_signature);
  if v_function is null then
   raise exception 'Missing required recovery RPC: %',v_signature;
  end if;
  select pg_catalog.pg_get_functiondef(v_function::oid) into v_definition;
  v_updated:=pg_catalog.regexp_replace(v_definition,
   'errcode\s*=\s*''40001''','errcode=''PT409''','gi');
  if v_updated<>v_definition then
   execute v_updated;
  elsif pg_catalog.strpos(v_definition,'PT409')=0 then
   raise exception 'Unexpected recovery RPC conflict contract: %',v_signature;
  end if;
 end loop;
end;
$recovery_business_conflicts$;
