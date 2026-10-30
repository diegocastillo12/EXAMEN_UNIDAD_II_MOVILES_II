-- These helpers are private. Only service RPCs below may supply a verified actor.
create or replace function public.match_case_snapshot(p_actor uuid,p_source text,p_case uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_data jsonb; v_owner uuid; v_kind text; v_photos jsonb; v_revision text;
begin
 if p_actor is null or p_source is null or p_source not in ('lost','found') or p_case is null then return null; end if;
 perform set_config('request.jwt.claims',jsonb_build_object('sub',p_actor,'role','authenticated')::text,true);
 if p_source='lost' then
  select owner_id,'own_loss' into v_owner,v_kind from public.lost_cases where id=p_case and status='active' and deleted_at is null;
  select r into v_data from public.read_recovery_pet_case(p_case) r where r->>'status'='active';
 else
  select owner_id,report_kind into v_owner,v_kind from public.found_cases where id=p_case and status='active' and deleted_at is null;
  select r into v_data from public.read_recovery_report(p_case) r where r->>'status'='active';
 end if;
 if v_owner is null or v_data is null or public.users_have_block(p_actor,v_owner) then return null; end if;
 select coalesce(jsonb_agg(jsonb_build_object('id',ph.id,'path',p.value->>'path','hash',ph.content_hash)
  order by ph.id),'[]'::jsonb) into v_photos
 from jsonb_array_elements(v_data->'photos') p(value)
 join lateral (
  select id,content_hash from public.pet_photos where p_source='lost' and id=(p.value->>'id')::uuid and status='published' and processed_at is not null
  union all
  select id,content_hash from public.found_case_photos where p_source='found' and id=(p.value->>'id')::uuid and status='ready' and processed_at is not null
 ) ph on true where ph.content_hash is not null;
 if jsonb_array_length(v_photos)=0 then return null; end if;
 v_revision=md5(jsonb_build_object('data',v_data-array['can_resolve','can_generate_poster'],'photos',v_photos)::text);
 select jsonb_agg(p.value||jsonb_build_object('embedding',e.embedding) order by p.value->>'id') into v_photos
 from jsonb_array_elements(v_photos) p(value)
 left join public.case_match_embeddings e on e.case_source=p_source and e.case_id=p_case
  and e.photo_id=(p.value->>'id')::uuid and e.photo_hash=p.value->>'hash' and e.case_revision=v_revision
  and e.model_version='clip-vit-b32-d15189d-q8-v1';
 return jsonb_build_object('source',p_source,'id',p_case,'owner',v_owner,'kind',v_kind,'revision',v_revision,
  'name',coalesce(v_data->>'pet_name',''),'species',v_data->>'species','occurred_at',v_data->>'occurred_at',
  'latitude',v_data->'latitude','longitude',v_data->'longitude','photos',v_photos);
end $$;

create or replace function public.read_case_match_context(p_actor uuid,p_source text,p_case uuid)
returns jsonb language plpgsql security definer set search_path='' set statement_timeout='8s' as $$
declare v_anchor jsonb; v_candidates jsonb; v_count integer;
begin
 if p_actor is null or not exists(select 1 from public.profiles where id=p_actor and onboarding_completed_at is not null) then
  raise exception using errcode='42501',message='matching_forbidden'; end if;
 v_anchor=public.match_case_snapshot(p_actor,p_source,p_case);
 if v_anchor is null or v_anchor->>'owner'<>p_actor::text or v_anchor->>'kind' not in ('own_loss','possible_loss') then
  raise exception using errcode='42501',message='matching_forbidden'; end if;
 -- Current independent reports retain their original meaning. Linked observations
 -- are never advertised as a newly discovered independent match.
 select coalesce(jsonb_agg(s.data order by c.published_at desc,c.id),'[]'::jsonb),count(*) into v_candidates,v_count
 from (select c.id,c.published_at,s.data from public.found_cases c
 cross join lateral (select public.match_case_snapshot(p_actor,'found',c.id) data) s
 where c.status='active' and c.deleted_at is null and c.report_kind in ('legacy_found','independent_found')
  and c.species=v_anchor->>'species' and not (p_source='found' and c.id=p_case) and s.data is not null
  order by c.published_at desc,c.id limit 101) c
 cross join lateral (select c.data) s;
 if v_count>100 then raise exception using errcode='54000',message='matching_scope_limit'; end if;
 return jsonb_build_object('anchor',v_anchor,'candidates',v_candidates,'reviews',coalesce((
  select jsonb_agg(jsonb_build_object('source',r.candidate_source,'id',r.candidate_id,'revision',r.candidate_revision,'decision',r.decision))
  from (select distinct on (candidate_source,candidate_id) * from public.case_match_reviews
   where actor_id=p_actor and anchor_source=p_source and anchor_id=p_case order by candidate_source,candidate_id,reviewed_at desc,command_id desc) r
  where r.actor_id=p_actor and r.anchor_source=p_source and r.anchor_id=p_case
   and r.anchor_revision=v_anchor->>'revision' and r.model_version='clip-vit-b32-d15189d-q8-v1'),'[]'::jsonb));
end $$;

create or replace function public.store_case_match_embedding(p_actor uuid,p_source text,p_case uuid,p_revision text,p_photo uuid,p_hash text,p_embedding real[])
returns void language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_case jsonb; v_norm double precision;
begin
 -- Serialize against lifecycle updates; visibility is revalidated after locking.
 if p_source='lost' then perform 1 from public.lost_cases where id=p_case for share;
 else perform 1 from public.found_cases where id=p_case for share; end if;
 if p_source='lost' then perform 1 from public.pet_photos where id=p_photo for share;
 else perform 1 from public.found_case_photos where id=p_photo for share; end if;
 v_case=public.match_case_snapshot(p_actor,p_source,p_case);
 if v_case is null or v_case->>'revision' is distinct from p_revision or not exists(
  select 1 from jsonb_array_elements(v_case->'photos') p where p->>'id'=p_photo::text and p->>'hash'=p_hash) then
  raise exception using errcode='PT409',message='matching_conflict'; end if;
 if p_embedding is null or cardinality(p_embedding)<>512 or array_ndims(p_embedding)<>1 or array_lower(p_embedding,1)<>1
  or array_position(p_embedding,null) is not null or exists(select 1 from unnest(p_embedding) x where x::text in ('NaN','Infinity','-Infinity')) then
  raise exception using errcode='22023',message='matching_invalid'; end if;
 select sum(x::double precision*x::double precision) into v_norm from unnest(p_embedding) x;
 if v_norm not between .999 and 1.001 then raise exception using errcode='22023',message='matching_invalid'; end if;
 insert into public.case_match_embeddings(case_source,case_id,photo_id,photo_hash,case_revision,model_version,embedding)
 values(p_source,p_case,p_photo,p_hash,p_revision,'clip-vit-b32-d15189d-q8-v1',p_embedding)
 on conflict(case_source,case_id,photo_id,model_version) do update
 set photo_hash=excluded.photo_hash,case_revision=excluded.case_revision,embedding=excluded.embedding,indexed_at=clock_timestamp();
end $$;

create or replace function public.review_case_match(p_actor uuid,p_command uuid,p_source text,p_case uuid,p_revision text,
 p_candidate_source text,p_candidate uuid,p_candidate_revision text,p_decision text)
returns void language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_context jsonb; v_saved public.case_match_reviews;
begin
 if p_actor is null or p_command is null or p_decision is null or p_decision not in ('confirmed','dismissed') then
  raise exception using errcode='22023',message='matching_invalid'; end if;
 perform pg_advisory_xact_lock(hashtextextended(p_command::text,41));
 perform pg_advisory_xact_lock(hashtextextended(p_actor::text||p_source||p_case::text,40));
 if p_source='lost' then perform 1 from public.lost_cases where id=p_case for share; end if;
 perform 1 from public.found_cases where id=p_candidate or (p_source='found' and id=p_case) order by id for share;
 v_context=public.read_case_match_context(p_actor,p_source,p_case);
 if v_context->'anchor'->>'revision' is distinct from p_revision or not exists(
  select 1 from jsonb_array_elements(v_context->'candidates') c
  where c->>'source'=p_candidate_source and c->>'id'=p_candidate::text and c->>'revision'=p_candidate_revision) then
  raise exception using errcode='PT409',message='matching_conflict'; end if;
 select * into v_saved from public.case_match_reviews where command_id=p_command;
 if found then
  if v_saved.actor_id<>p_actor or v_saved.anchor_source<>p_source or v_saved.anchor_id<>p_case or v_saved.anchor_revision<>p_revision
   or v_saved.candidate_source<>p_candidate_source or v_saved.candidate_id<>p_candidate or v_saved.candidate_revision<>p_candidate_revision or v_saved.decision<>p_decision then
   raise exception using errcode='PT409',message='matching_conflict'; end if;
  return;
 end if;
 insert into public.case_match_reviews values(p_command,p_actor,p_source,p_case,p_revision,p_candidate_source,p_candidate,p_candidate_revision,
  'clip-vit-b32-d15189d-q8-v1',p_decision,clock_timestamp());
end $$;
