import 'case_cache_database.dart';
import 'package:drift/drift.dart';

CaseCacheDatabase openCaseCacheDatabase() => CaseCacheDatabase(
  LazyDatabase(() async => throw UnsupportedError('Native cache only')),
);
