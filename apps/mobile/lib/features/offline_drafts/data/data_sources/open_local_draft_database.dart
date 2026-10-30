import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'local_draft_database.dart';

LocalDraftDatabase openLocalDraftDatabase() => LocalDraftDatabase(
  LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    return NativeDatabase.createInBackground(
      File(path.join(directory.path, 'report_drafts.sqlite')),
    );
  }),
);
