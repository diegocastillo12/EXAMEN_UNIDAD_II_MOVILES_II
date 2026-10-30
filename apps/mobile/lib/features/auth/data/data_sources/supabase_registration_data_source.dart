import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/registration_result_dto.dart';
import 'registration_data_source.dart';

final class SupabaseRegistrationDataSource implements RegistrationDataSource {
  const SupabaseRegistrationDataSource(this._client, {this.redirectUri});
  final SupabaseClient _client;
  final String? redirectUri;

  Future<T> _execute<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (error, stack) {
      final kind = switch (error.code) {
        'email_address_invalid' => RegistrationSourceFailureKind.invalidEmail,
        'otp_expired' ||
        'otp_disabled' => RegistrationSourceFailureKind.invalidCode,
        'weak_password' => RegistrationSourceFailureKind.weakPassword,
        'user_already_exists' ||
        'email_exists' => RegistrationSourceFailureKind.alreadyRegistered,
        'over_email_send_rate_limit' ||
        'over_request_rate_limit' => RegistrationSourceFailureKind.rateLimited,
        _ => RegistrationSourceFailureKind.unavailable,
      };
      Error.throwWithStackTrace(RegistrationSourceFailure(kind), stack);
    } on RegistrationSourceFailure {
      rethrow;
    } catch (_, stack) {
      Error.throwWithStackTrace(
        const RegistrationSourceFailure(
          RegistrationSourceFailureKind.unavailable,
        ),
        stack,
      );
    }
  }

  @override
  Future<RegistrationResultDto> register({
    required String name,
    required String email,
    required String password,
  }) => _execute(() async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
      emailRedirectTo: redirectUri,
    );
    if (response.user == null) {
      throw const RegistrationSourceFailure(
        RegistrationSourceFailureKind.unavailable,
      );
    }
    return RegistrationResultDto(hasSession: response.session != null);
  });

  @override
  Future<void> resendConfirmation(String email) => _execute(() async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: redirectUri,
    );
  });

  @override
  Future<void> verifyCode(String email, String code) => _execute(() async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
    if (response.session == null || response.user == null) {
      throw const RegistrationSourceFailure(
        RegistrationSourceFailureKind.invalidCode,
      );
    }
  });
}
