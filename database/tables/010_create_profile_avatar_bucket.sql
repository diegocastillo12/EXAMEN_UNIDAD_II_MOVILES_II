-- HU-01.7 expanded by the user: private account avatar, stable retry path.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('profile-avatars', 'profile-avatars', false, 2097152, array['image/jpeg'])
on conflict (id) do update set
    public = false, file_size_limit = 2097152, allowed_mime_types = array['image/jpeg'];
