-- Incident recovery, 2026-10-10: PostgREST PID 473812 remained idle in transaction.
-- Execute alone in a new SQL Editor query. This is not a migration.
-- Termination rolls back uncommitted work in this session.
-- Recheck live state: do nothing if the session is gone, no longer idle in
-- transaction, waits behind another backend, or no longer blocks a session.
select candidate.pid,
       pg_catalog.pg_terminate_backend(candidate.pid) as termination_requested
from pg_catalog.pg_stat_activity candidate
where candidate.datname = current_database()
  and candidate.pid = 473812
  and candidate.pid <> pg_backend_pid()
  and candidate.application_name like 'PostgREST%'
  and candidate.state = 'idle in transaction'
  and candidate.xact_start is not null
  and cardinality(pg_catalog.pg_blocking_pids(candidate.pid)) = 0
  and exists (
    select 1
    from pg_catalog.pg_stat_activity waiting
    where waiting.datname = candidate.datname
      and waiting.pid <> pg_backend_pid()
      and candidate.pid = any(pg_catalog.pg_blocking_pids(waiting.pid))
  );
