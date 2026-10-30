import '../services/pet_changes.dart';

class NotifyPetChanged {
  const NotifyPetChanged(this._changes);
  final PetChanges _changes;
  void call(String ownerId, String petId) => _changes.notify(ownerId, petId);
}
