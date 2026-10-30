create trigger entrehuellas_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_auth_user();

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_profile_updated_at();
