import 'dart:async';
import 'package:flutter_application_entrehuellas/features/profile/domain/entities/account_profile.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/failures/profile_failure.dart';

class FakeProfile implements ProfileRepository {
  final profiles = <String, AccountProfile>{};
  bool failRead = false;
  bool failUpdate = false;
  int reads = 0;
  int updates = 0;
  Completer<void>? pendingUpdate;
  Completer<void>? pendingRead;
  @override
  Future<AccountProfile> read(String userId) async {
    reads++;
    await pendingRead?.future;
    if (failRead) throw const ProfileFailure(ProfileFailureKind.unavailable);
    return profiles[userId] ??
        AccountProfile(
          userId: userId,
          displayName: 'Ana',
          city: 'Lima',
          email: 'ana@example.invalid',
        );
  }

  @override
  Future<AccountProfile> update(
    String userId, {
    required String? displayName,
    required String? city,
    required String? contactPhone,
  }) async {
    updates++;
    await pendingUpdate?.future;
    if (failUpdate) throw const ProfileFailure(ProfileFailureKind.unavailable);
    return profiles[userId] = AccountProfile(
      userId: userId,
      displayName: displayName,
      city: city,
      contactPhone: contactPhone,
      email: profiles[userId]?.email ?? 'ana@example.invalid',
      avatarUri: profiles[userId]?.avatarUri,
    );
  }
}
