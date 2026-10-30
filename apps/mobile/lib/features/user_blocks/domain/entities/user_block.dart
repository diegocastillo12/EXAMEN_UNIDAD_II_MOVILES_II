typedef BlockTarget = ({String kind, String id});

enum BlockIssue { invalid, forbidden, conflict, unavailable }

class BlockFailure implements Exception {
  const BlockFailure(this.issue);
  final BlockIssue issue;
}

class UserBlock {
  const UserBlock({
    required this.id,
    required this.label,
    required this.enabled,
    required this.version,
  });
  final String id, label;
  final bool enabled;
  final int version;
}

class UserBlockPage {
  const UserBlockPage(this.items, this.next);
  final List<UserBlock> items;
  final String? next;
}

class BlockChange {
  const BlockChange(this.entry, this.enabled);
  final UserBlock entry;
  final bool enabled;
}
