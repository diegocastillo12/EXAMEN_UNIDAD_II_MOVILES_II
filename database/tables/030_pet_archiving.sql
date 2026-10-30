alter table public.pets add column if not exists archived_at timestamptz;
-- Server-owned case guards. Case publication/closure must maintain them under
-- the same parent-row lock, in the transaction that creates/closes the case.
alter table public.pets add column if not exists case_history_at timestamptz;
alter table public.pets add column if not exists active_case_count integer not null default 0;
do $$ begin
  if not exists(select 1 from pg_catalog.pg_constraint where conrelid='public.pets'::regclass and conname='pets_case_lifecycle') then
    alter table public.pets add constraint pets_case_lifecycle check (
      active_case_count >= 0
      and (active_case_count = 0 or case_history_at is not null)
      and (archived_at is null or active_case_count = 0)
    );
  end if;
end; $$;
comment on column public.pets.archived_at is 'Archived pets remain private and recoverable; active lists filter this column to NULL.';
comment on column public.pets.case_history_at is 'Irreversible server-owned first case timestamp. Case publication must set this atomically; never supplied by client.';
comment on column public.pets.active_case_count is 'Server-owned number of active cases; case commands must maintain this atomically under the pet row lock.';
