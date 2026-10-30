import 'package:drift/drift.dart';
import 'local_draft_database.dart';

LocalDraftDatabase openLocalDraftDatabase() => LocalDraftDatabase(
  LazyDatabase(
    () async =>
        throw UnsupportedError('Native SQLite is required for Android drafts.'),
  ),
);
