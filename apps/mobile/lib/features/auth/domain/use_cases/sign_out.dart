import '../repositories/access_repository.dart';

final class SignOut {
  const SignOut(this._repository);
  final AccessRepository _repository;
  Future<void> call() => _repository.signOut();
}
