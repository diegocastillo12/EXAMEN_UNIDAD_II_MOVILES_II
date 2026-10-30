-- HU-05 / RF-05: stop lock waits before the client publication deadline.
-- Function-local configuration preserves auth, RLS, search_path and deduplication.
-- A timeout aborts the command; it never bypasses the pet lock or validation.
alter function public.publish_lost_case(uuid,uuid,integer,timestamptz,double precision,double precision,text,uuid[])
    set lock_timeout = '5s';
