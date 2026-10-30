import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_session_dto.dart';
import 'auth_remote_data_source.dart';
import 'auth_access_data_source.dart';
import '../../domain/entities/social_provider.dart';

final class SupabaseAuthDataSource
    implements AuthRemoteDataSource, AuthAccessDataSource {
  SupabaseAuthDataSource(this._client, {this.redirectUri});

  final SupabaseClient _client;
  final String? redirectUri;

  Future<void> _execute(Future<void> Function() action) async {
    try {
      await action();
    } on AuthException catch (error, stack) {
      final kind = switch (error.code) {
        'invalid_credentials' => AccessSourceFailureKind.rejected,
        'email_not_confirmed' => AccessSourceFailureKind.emailNotConfirmed,
        _ => AccessSourceFailureKind.unavailable,
      };
      Error.throwWithStackTrace(AccessSourceFailure(kind), stack);
    } on AccessSourceFailure {
      rethrow;
    } catch (_, stack) {
      Error.throwWithStackTrace(
        const AccessSourceFailure(AccessSourceFailureKind.unavailable),
        stack,
      );
    }
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) => _execute(() async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.session == null) {
      throw const AccessSourceFailure(AccessSourceFailureKind.rejected);
    }
  });

  @override
  Future<void> signInWithProvider(SocialProvider provider) =>
      _execute(() async {
        final launched = await _client.auth.signInWithOAuth(switch (provider) {
          SocialProvider.apple => OAuthProvider.apple,
          SocialProvider.google => OAuthProvider.google,
          SocialProvider.facebook => OAuthProvider.facebook,
        }, redirectTo: redirectUri);
        if (!launched) {
          throw const AccessSourceFailure(AccessSourceFailureKind.unavailable);
        }
      });

  @override
  Future<void> signOut() =>
      _execute(() => _client.auth.signOut(scope: SignOutScope.local));

  @override
  Stream<AuthSessionDto?> watchSession() async* {
    yield _projectSession(_client.auth.currentSession);
    yield* _client.auth.onAuthStateChange.map(
      (event) => _projectSession(event.session),
    );
  }

  AuthSessionDto? _projectSession(Session? session) =>
      session == null ? null : AuthSessionDto(userId: session.user.id);
}
