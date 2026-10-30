-- Re-runnable guard. Existing incomplete rows are preserved until their metadata is edited.
drop trigger if exists pets_required_fields_guard on public.pets;
create trigger pets_required_fields_guard
before insert or update of name, species, sex, age_months, traits, species_detail, size
on public.pets for each row execute function public.enforce_pet_required_fields();
