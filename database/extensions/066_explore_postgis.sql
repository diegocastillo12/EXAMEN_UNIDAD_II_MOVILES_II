-- Keep extension objects outside the exposed public schema.
create schema if not exists extensions;
create extension if not exists postgis with schema extensions;
do $$ begin
    if (select extnamespace from pg_extension where extname='postgis') <> 'extensions'::regnamespace then
        raise exception 'explore_postgis_schema: PostGIS must be installed in extensions';
    end if;
end $$;
