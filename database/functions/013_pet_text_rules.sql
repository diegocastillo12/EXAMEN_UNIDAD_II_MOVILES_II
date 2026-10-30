-- Match Dart trim for ordinary and Unicode space characters.
create or replace function public.pet_trim(p_value text) returns text
language sql immutable strict set search_path = '' as $$
  select btrim(p_value, E' \t\n\r\f\v' || U&'\0085\00A0\1680\2000\2001\2002\2003\2004\2005\2006\2007\2008\2009\200A\2028\2029\202F\205F\3000\FEFF');
$$;
create or replace function public.validate_pet_fields(p_name text, p_species text, p_sex text, p_age_months integer, p_traits text)
returns void language plpgsql set search_path = '' as $$
begin
  if p_name is null or char_length(p_name) not between 1 and 80 then raise exception using errcode = '23514', message = 'pet_invalid_name'; end if;
  if p_species is null or p_species not in ('dog', 'cat', 'other') then raise exception using errcode = '23514', message = 'pet_invalid_species'; end if;
  if p_sex is not null and p_sex not in ('male', 'female') then raise exception using errcode = '23514', message = 'pet_invalid_species'; end if;
  if p_age_months is not null and p_age_months not between 0 and 600 then raise exception using errcode = '23514', message = 'pet_invalid_age'; end if;
  if p_traits is not null and char_length(p_traits) > 500 then raise exception using errcode = '23514', message = 'pet_invalid_traits'; end if;
end;
$$;
