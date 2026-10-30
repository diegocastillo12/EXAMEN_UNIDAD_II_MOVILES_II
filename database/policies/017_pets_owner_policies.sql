alter table public.pets enable row level security;
do $pets_rls$
begin
  if not exists(select 1 from pg_catalog.pg_policy where polrelid='public.pets'::regclass and polname='pets_select_own') then
    create policy pets_select_own on public.pets for select to authenticated using(owner_id=(select auth.uid()));
  end if;
end;
$pets_rls$;
