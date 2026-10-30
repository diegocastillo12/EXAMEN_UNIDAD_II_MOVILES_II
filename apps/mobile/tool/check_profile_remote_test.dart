// Opt-in: use two dedicated development accounts, never production accounts.
// Credentials are supplied as dart defines from an ignored local JSON file.
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/profile/data/data_sources/supabase_profile_data_source.dart';
import 'package:flutter_application_entrehuellas/features/profile/data/repositories/profile_repository_impl.dart';

void main() {
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  const emailA = String.fromEnvironment('PROFILE_TEST_EMAIL_A');
  const passwordA = String.fromEnvironment('PROFILE_TEST_PASSWORD_A');
  const emailB = String.fromEnvironment('PROFILE_TEST_EMAIL_B');
  const passwordB = String.fromEnvironment('PROFILE_TEST_PASSWORD_B');
  final configured = [
    url,
    key,
    emailA,
    passwordA,
    emailB,
    passwordB,
  ].every((value) => value.isNotEmpty);
  test(
    'Development profiles: persistence across sessions, isolation and protected columns',
    () async {
      final a = SupabaseClient(url, key);
      final b = SupabaseClient(url, key);
      final restored = SupabaseClient(url, key);
      addTearDown(() async {
        await a.dispose();
        await b.dispose();
        await restored.dispose();
      });
      await a.auth.signInWithPassword(email: emailA, password: passwordA);
      await b.auth.signInWithPassword(email: emailB, password: passwordB);
      final aId = a.auth.currentUser!.id;
      final bId = b.auth.currentUser!.id;
      expect(
        aId,
        isNot(bId),
        reason: 'Two distinct development accounts are required.',
      );
      final repo = ProfileRepositoryImpl(SupabaseProfileDataSource(a));
      final original = await repo.read(aId);
      try {
        final saved = await repo.update(
          aId,
          displayName: 'Profile integration check',
          city: 'Lima',
          contactPhone: original.contactPhone,
        );
        expect(saved.displayName, 'Profile integration check');
        await repo.update(
          aId,
          displayName: saved.displayName,
          city: saved.city,
          contactPhone: saved.contactPhone,
        );
        await restored.auth.signInWithPassword(
          email: emailA,
          password: passwordA,
        );
        final reread = await ProfileRepositoryImpl(
          SupabaseProfileDataSource(restored),
        ).read(aId);
        expect(reread.displayName, saved.displayName);
        expect(reread.city, saved.city);
        expect(
          await b
              .from('profiles')
              .select('id,display_name,city')
              .eq('id', aId)
              .maybeSingle(),
          isNull,
        );
        final changed = await b
            .from('profiles')
            .update({'city': 'Unauthorized'})
            .eq('id', aId)
            .select('id');
        expect(changed, isEmpty);
        for (final entry in {
          'id': aId,
          'created_at': '2000-01-01T00:00:00Z',
          'updated_at': '2000-01-01T00:00:00Z',
          'onboarding_completed_at': null,
        }.entries) {
          await expectLater(
            a.from('profiles').update({entry.key: entry.value}).eq('id', aId),
            throwsA(
              isA<PostgrestException>().having(
                (error) => error.code,
                'permission code',
                '42501',
              ),
            ),
          );
        }
        expect((await repo.read(aId)).city, 'Lima');
      } finally {
        // Restore editable values even if an assertion fails.
        await repo.update(
          aId,
          displayName: original.displayName,
          city: original.city,
          contactPhone: original.contactPhone,
        );
      }
    },
    skip: configured
        ? false
        : 'Two authenticated development accounts have not been configured.',
  );
}
