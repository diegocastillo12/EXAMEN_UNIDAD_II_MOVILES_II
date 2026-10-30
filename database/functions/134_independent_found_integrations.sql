-- Extend existing public-case operations to the explicitly approved new kind.
-- Preserve authorization, public projections, consent, budgets, settings and ACLs.
do $independent_found_integrations$
declare v_name text; v_function regprocedure; v_definition text; v_updated text;
begin
 foreach v_name in array array['prepare_case_poster','prepare_case_share','read_recovery_report',
  'read_qr_case','revoke_case_public_link','authorized_timeline_case','alert_case','persist_sighting'] loop
  select p.oid::regprocedure into strict v_function from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.proname=v_name;
  v_definition=pg_get_functiondef(v_function::oid);
  v_updated=replace(v_definition,'(''own_loss'',''possible_loss'',''legacy_found'')',
   '(''own_loss'',''possible_loss'',''legacy_found'',''independent_found'')');
  v_updated=replace(v_updated,'(''possible_loss'',''legacy_found'')',
   '(''possible_loss'',''legacy_found'',''independent_found'')');
  if v_updated=v_definition and strpos(v_updated,'''independent_found''')=0 then
   raise exception 'Unexpected independent found integration: %',v_name; end if;
  if v_updated<>v_definition then execute v_updated; end if;
 end loop;
end;
$independent_found_integrations$;
