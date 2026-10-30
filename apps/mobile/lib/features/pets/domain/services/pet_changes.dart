import 'dart:async';

/// Scope-owned domain notifications after confirmed mutations; no cached data.
class PetChanges {
  final _events = StreamController<({String ownerId, String petId})>.broadcast(
    sync: true,
  );
  Stream<void> watch(String ownerId, {String? petId}) => _events.stream
      .where(
        (event) =>
            event.ownerId == ownerId && (petId == null || event.petId == petId),
      )
      .map((_) {});
  void notify(String ownerId, String petId) =>
      _events.add((ownerId: ownerId, petId: petId));
  Future<void> dispose() => _events.close();
}
