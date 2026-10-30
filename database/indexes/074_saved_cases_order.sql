create index if not exists saved_cases_owner_order_idx
 on public.saved_cases(owner_id,updated_at desc,case_source desc,case_id desc) where saved;
