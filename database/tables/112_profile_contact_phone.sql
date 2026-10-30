-- Private optional contact number; existing accounts remain without a number.
alter table public.profiles add column if not exists contact_phone text;
do $profile_phone$
begin
 if not exists(select 1 from pg_catalog.pg_constraint where conrelid='public.profiles'::regclass and conname='profiles_contact_phone_format') then
  alter table public.profiles add constraint profiles_contact_phone_format
   check(contact_phone is null or (char_length(contact_phone) between 9 and 16 and contact_phone ~ '^\+[1-9][0-9]{7,14}$'));
 end if;
end;
$profile_phone$;
