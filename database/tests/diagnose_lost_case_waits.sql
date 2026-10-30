-- Read-only: run in Supabase SQL Editor while publication is waiting.
-- Does not expose query text, report fields, identities or credentials.
-- One result: SQL Editor shows only the final result when there are two queries.
with activity as materialized (
  select pid, state, application_name, wait_event_type, wait_event,
         xact_start, query_start, pg_blocking_pids(pid) as blocked_by,
         case
           when query ilike '%publish_lost_case%' then 'publish_lost_case'
           when query ilike '%pet_photo%' then 'pet_photo_operation'
           when query ilike '%update_pet%' then 'update_pet'
           when query ~* '^[[:space:]]*(begin|start transaction)' then 'begin'
           when query ~* '^[[:space:]]*commit' then 'commit'
           when query ~* '^[[:space:]]*rollback' then 'rollback'
           else 'other'
         end as operation
  from pg_catalog.pg_stat_activity
  where datname = current_database() and pid <> pg_backend_pid()
), blockers as (
  select distinct unnest(blocked_by) as pid from activity
)
select a.pid, a.state, a.application_name, a.operation,
       a.wait_event_type, a.wait_event, a.blocked_by,
       (b.pid is not null and cardinality(a.blocked_by) = 0) as root_blocker,
       clock_timestamp() - a.xact_start as transaction_age
from activity a
left join blockers b on b.pid = a.pid
where b.pid is not null or cardinality(a.blocked_by) > 0
   or a.state like 'idle in transaction%'
order by root_blocker desc, a.xact_start;
