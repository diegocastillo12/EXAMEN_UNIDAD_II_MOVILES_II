do $$ begin
  if not exists(select 1 from pg_catalog.pg_trigger where tgrelid='public.pets'::regclass and tgname='pet_case_history_guard' and not tgisinternal) then
    create trigger pet_case_history_guard before update or delete on public.pets for each row execute function public.protect_pet_case_history();
  end if;
end; $$;
