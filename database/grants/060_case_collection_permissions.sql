revoke all on function public.delete_lost_case(uuid),public.delete_found_case(uuid),public.list_my_lost_case_cards(),public.list_my_found_case_cards() from public,anon,authenticated;
grant execute on function public.delete_lost_case(uuid),public.delete_found_case(uuid),public.list_my_lost_case_cards(),public.list_my_found_case_cards() to authenticated;
