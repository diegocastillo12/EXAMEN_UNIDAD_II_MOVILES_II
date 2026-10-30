-- Read-only: run in the SQL Editor of the same database used by the app.
-- Does not query user data or modify schema/permissions.
with expected(signature) as (
    values ('public.list_my_lost_case_cards()'),
           ('public.list_my_found_case_cards()')
), functions as (
    select signature, pg_catalog.to_regprocedure(signature) as function_oid
    from expected
)
select signature,
       function_oid is not null as function_exists,
       case when function_oid is not null then
           pg_catalog.has_function_privilege('authenticated', function_oid, 'execute')
       end as authenticated_can_execute,
       case when function_oid is not null then
           pg_catalog.has_function_privilege('anon', function_oid, 'execute')
       end as anon_can_execute
from functions
order by signature;
