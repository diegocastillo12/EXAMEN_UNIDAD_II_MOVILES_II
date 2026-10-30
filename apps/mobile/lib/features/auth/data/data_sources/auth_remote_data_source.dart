import '../models/auth_session_dto.dart';

abstract interface class AuthRemoteDataSource {
  Stream<AuthSessionDto?> watchSession();
}
