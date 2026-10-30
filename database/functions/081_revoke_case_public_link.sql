create or replace function public.revoke_case_public_link(p_source text,p_id uuid)
returns void language plpgsql security definer set search_path='' set lock_timeout='3s' as $$
declare v_actor uuid:=auth.uid(); v_owner uuid;
begin
 if v_actor is null then raise exception using errcode='42501',message='link_unauthorized'; end if;
 if p_source='lost' then select owner_id into v_owner from public.lost_cases where id=p_id for share;
 elsif p_source='found' then select owner_id into v_owner from public.found_cases where id=p_id and report_kind in ('possible_loss','legacy_found') for share;
 end if;
 if v_owner is distinct from v_actor then raise exception using errcode='42501',message='link_unauthorized'; end if;
 update public.case_public_links set revoked_at=coalesce(revoked_at,clock_timestamp())
 where case_source=p_source and case_id=p_id and owner_id=v_actor;
end $$;
