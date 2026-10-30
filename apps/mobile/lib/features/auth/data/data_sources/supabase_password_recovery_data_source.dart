import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recovery_access_dto.dart';
import 'password_recovery_data_source.dart';

final class SupabasePasswordRecoveryDataSource
    implements PasswordRecoveryDataSource {
  SupabasePasswordRecoveryDataSource(this._client, {this.redirectUri});
  final SupabaseClient _client;
  final String? redirectUri;
  bool _active = false;
  String? _recoveryUserId;

  Future<void> _execute(Future<void> Function() action) async {
    try {
      await action();
    } on AuthException catch (error, stack) {
      final kind = switch (error.code) {
        'email_address_invalid' => RecoverySourceFailureKind.invalidEmail,
        'weak_password' => RecoverySourceFailureKind.weakPassword,
        'same_password' => RecoverySourceFailureKind.samePassword,
        'otp_expired' ||
        'session_not_found' ||
        'refresh_token_not_found' ||
        'bad_jwt' ||
        'user_not_found' => RecoverySourceFailureKind.invalidLink,
        'over_email_send_rate_limit' ||
        'over_request_rate_limit' => RecoverySourceFailureKind.rateLimited,
        _ => RecoverySourceFailureKind.unavailable,
      };
      Error.throwWithStackTrace(RecoverySourceFailure(kind), stack);
    } on RecoverySourceFailure {
      rethrow;
    } catch (_, stack) {
      Error.throwWithStackTrace(
        const RecoverySourceFailure(RecoverySourceFailureKind.unavailable),
        stack,
      );
    }
  }

  @override
  Stream<RecoveryAccessDto> watchAccess() => Stream.multi((output) {
    // Subscribe before emitting the initial value. The SDK replays its latest
    // event, including a recovery callback received during cold startup.
    final subscription = _client.auth.onAuthStateChange.listen(
      (event) {
        if (event.event == AuthChangeEvent.passwordRecovery &&
            event.session != null) {
          _active = true;
          _recoveryUserId = event.session!.user.id;
        } else if (event.event == AuthChangeEvent.signedOut ||
            event.event == AuthChangeEvent.signedIn ||
            (_active && event.session?.user.id != _recoveryUserId)) {
          _active = false;
          _recoveryUserId = null;
        }
        output.add(RecoveryAccessDto(active: _active));
      },
      onError: (Object error, StackTrace stack) {
        if (error is AuthPKCEGrantCodeExchangeError ||
            (error is AuthException &&
                (error.code == 'otp_expired' ||
                    error.code == 'access_denied' ||
                    error.statusCode == 'otp_expired'))) {
          output.add(const RecoveryAccessDto(invalid: true));
        } else if (_active) {
          output.addError(
            const RecoverySourceFailure(RecoverySourceFailureKind.unavailable),
            stack,
          );
        } else {
          // Normal login/OAuth observation failures belong to auth's gate.
          output.add(const RecoveryAccessDto());
        }
      },
      onDone: output.close,
    );
    output.add(RecoveryAccessDto(active: _active));
    output.onCancel = subscription.cancel;
    output.onPause = subscription.pause;
    output.onResume = subscription.resume;
  });

  @override
  Future<void> sendCode(String email) => _execute(() async {
    try {
      await _client.auth.resetPasswordForEmail(email, redirectTo: redirectUri);
    } on AuthException catch (error) {
      // Preserve the same confirmation for existing and unknown accounts.
      if (error.code != 'user_not_found') rethrow;
    }
  });

  @override
  Future<void> verifyCode(String email, String code) => _execute(() async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.recovery,
      );
      if (response.session == null || response.user == null) {
        throw const RecoverySourceFailure(
          RecoverySourceFailureKind.invalidCode,
        );
      }
      // Establish the context before returning, even if the stream notification
      // has not reached the router yet. Never infer it from a submitted code.
      _active = true;
      _recoveryUserId = response.user!.id;
    } on AuthException catch (error) {
      if (error.code == 'otp_expired' ||
          error.code == 'otp_disabled' ||
          error.code == 'access_denied') {
        throw const RecoverySourceFailure(
          RecoverySourceFailureKind.invalidCode,
        );
      }
      rethrow;
    }
  });

  @override
  Future<void> updatePassword(String password) => _execute(() async {
    if (!_active || _client.auth.currentUser?.id != _recoveryUserId) {
      throw const RecoverySourceFailure(RecoverySourceFailureKind.invalidLink);
    }
    await _client.auth.updateUser(UserAttributes(password: password));
    // Keep the recovery gate until the user acknowledges success or cancels.
  });

  @override
  Future<void> endRecovery() => _execute(() async {
    await _client.auth.signOut(scope: SignOutScope.local);
    _active = false;
    _recoveryUserId = null;
  });
}
