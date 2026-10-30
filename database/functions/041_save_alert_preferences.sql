create or replace function public.save_alert_preferences(
    p_expected_version integer, p_enabled boolean, p_lost_pets boolean,
    p_found_pets boolean, p_case_updates boolean, p_in_app boolean, p_push boolean
) returns public.alert_preferences
language plpgsql security definer set search_path = '' as $$
declare
    actor uuid := auth.uid();
    current_preferences public.alert_preferences;
    identical boolean;
begin
    if actor is null then raise exception 'preferences_signed_out' using errcode = '42501'; end if;
    if p_expected_version is null or p_expected_version < 0 or p_expected_version >= 2147483647
       or p_enabled is null or p_lost_pets is null or p_found_pets is null
       or p_case_updates is null or p_in_app is null or p_push is null
       or (p_enabled and not (p_lost_pets or p_found_pets or p_case_updates))
       or (p_enabled and not (p_in_app or p_push)) then
        raise exception 'preferences_invalid' using errcode = '22023';
    end if;
    -- Account identity and expected version remain stable across a lost response.
    perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('alert_preferences/' || actor::text, 0));
    select * into current_preferences from public.alert_preferences where owner_id = actor for update;
    if found then
        identical := current_preferences.enabled = p_enabled
          and current_preferences.lost_pets = p_lost_pets and current_preferences.found_pets = p_found_pets
          and current_preferences.case_updates = p_case_updates and current_preferences.in_app = p_in_app
          and current_preferences.push = p_push;
        if identical and current_preferences.version = p_expected_version + 1 then
            return current_preferences;
        end if;
        if current_preferences.version <> p_expected_version then
            raise exception 'preferences_conflict' using errcode = '40001';
        end if;
        if identical then return current_preferences; end if;
        update public.alert_preferences set enabled = p_enabled, lost_pets = p_lost_pets,
            found_pets = p_found_pets, case_updates = p_case_updates, in_app = p_in_app, push = p_push,
            version = version + 1, updated_at = now()
            where owner_id = actor returning * into current_preferences;
    else
        if p_expected_version <> 0 then raise exception 'preferences_conflict' using errcode = '40001'; end if;
        insert into public.alert_preferences(owner_id, enabled, lost_pets, found_pets, case_updates, in_app, push)
            values(actor, p_enabled, p_lost_pets, p_found_pets, p_case_updates, p_in_app, p_push)
            returning * into current_preferences;
    end if;
    return current_preferences;
end;
$$;
