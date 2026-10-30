-- HU-03 / RF-03: required metadata for new/edited pets, without fabricating legacy values.
-- Only metadata writes invoke this guard; archive/delete lifecycle updates remain possible.
create or replace function public.enforce_pet_required_fields()
returns trigger language plpgsql set search_path = '' as $$
begin
    perform public.validate_pet_fields(new.name, new.species, new.sex, new.age_months, new.traits);
    if new.species = 'other' and
       (new.species_detail is null or char_length(public.pet_trim(new.species_detail)) not between 1 and 60) then
        raise exception using errcode = '23514', message = 'pet_invalid_species_detail';
    end if;
    if new.size is null or new.size not in ('small', 'medium', 'large') then
        raise exception using errcode = '23514', message = 'pet_invalid_size';
    end if;
    if new.age_months is null or new.age_months not between 0 and 600 then
        raise exception using errcode = '23514', message = 'pet_invalid_age';
    end if;
    if new.traits is null or char_length(public.pet_trim(new.traits)) not between 1 and 200 then
        raise exception using errcode = '23514', message = 'pet_invalid_traits';
    end if;
    return new;
end;
$$;
revoke all on function public.enforce_pet_required_fields() from public, anon, authenticated;
