-- Bound transaction lock waits without changing authorization or function bodies.
alter function public.prepare_found_case(uuid,uuid[]) set lock_timeout = '5s';
alter function public.prepare_found_case_photo(uuid,uuid,uuid,text) set lock_timeout = '5s';
alter function public.complete_found_case_photo(uuid,uuid,uuid,text) set lock_timeout = '5s';
alter function public.publish_found_case(uuid,timestamptz,double precision,double precision,text,text,text,text,text,text,text,uuid[]) set lock_timeout = '5s';
alter function public.begin_found_case_discard(uuid) set lock_timeout = '5s';
alter function public.finish_found_case_discard(uuid) set lock_timeout = '5s';
