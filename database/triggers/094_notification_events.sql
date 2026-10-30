-- No backfill: installing HU-12 does not fabricate notifications for previous events.
drop trigger if exists alerts_case_event on public.case_events;
create trigger alerts_case_event after insert on public.case_events for each row execute function public.notification_event_trigger();
drop trigger if exists alerts_found_event on public.found_case_events;
create trigger alerts_found_event after insert on public.found_case_events for each row execute function public.notification_event_trigger();
drop trigger if exists alerts_sighting on public.public_sightings;
create trigger alerts_sighting after insert on public.public_sightings for each row execute function public.notification_event_trigger();
drop trigger if exists alerts_review on public.sighting_reviews;
create trigger alerts_review after insert on public.sighting_reviews for each row execute function public.notification_event_trigger();
