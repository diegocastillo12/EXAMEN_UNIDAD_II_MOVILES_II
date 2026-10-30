revoke all on public.content_reports,public.content_report_reviewers from public,anon,authenticated,service_role;
revoke all on function public.authorize_report_resource(text,uuid) from public,anon,authenticated,service_role;
revoke all on function public.submit_content_report(uuid,text,uuid,text,text) from public,anon,authenticated,service_role;
revoke all on function public.read_content_report(uuid) from public,anon,authenticated,service_role;
grant execute on function public.submit_content_report(uuid,text,uuid,text,text) to authenticated;
grant execute on function public.read_content_report(uuid) to authenticated;
