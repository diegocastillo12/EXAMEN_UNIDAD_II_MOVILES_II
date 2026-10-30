-- Recovery for the PostgREST PIDs observed on 2026-10-10.
-- Cancel only a currently waiting publication statement in that PID list.
-- PostgREST must roll back the canceled transaction. Already committed reports remain.
-- This is an operational recovery, not a schema migration or an automatic cleanup.
select pid, pg_catalog.pg_cancel_backend(pid) as cancellation_requested
from pg_catalog.pg_stat_activity
where datname = current_database()
  and pid in (476153,475979,474663,475811,473812,475133,474035,475511,476217)
  and pid <> pg_backend_pid()
  and application_name like 'PostgREST%'
  and state = 'active'
  and wait_event_type = 'Lock'
  and query ilike '%publish_lost_case%';
