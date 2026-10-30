import 'package:drift/drift.dart';

class CaseCacheDatabase extends GeneratedDatabase {
  CaseCacheDatabase(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) => customStatement('''
    CREATE TABLE case_cache(owner TEXT NOT NULL, source TEXT NOT NULL, id TEXT NOT NULL,
    stored_at INTEGER NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(owner, source, id))
  '''),
  );

  Future<List<String>> rows(
    String owner, {
    String? source,
    String? id,
  }) async => (await customSelect(
    'SELECT payload FROM case_cache WHERE owner=? ${source == null ? '' : 'AND source=? AND id=?'} ORDER BY stored_at DESC,source,id',
    variables: [
      Variable(owner),
      if (source != null) ...[Variable(source), Variable(id!)],
    ],
  ).get()).map((r) => r.read<String>('payload')).toList();

  Future<void> put(
    String owner,
    String source,
    String id,
    int time,
    String payload,
  ) => transaction(() async {
    await customStatement(
      'INSERT OR REPLACE INTO case_cache(owner,source,id,stored_at,payload) VALUES(?,?,?,?,?)',
      [owner, source, id, time, payload],
    );
    // Bounded cache shared by the device, not an unbounded photo archive.
    await customStatement(
      'DELETE FROM case_cache WHERE rowid NOT IN (SELECT rowid FROM case_cache ORDER BY stored_at DESC,rowid DESC LIMIT 30)',
    );
    while ((await customSelect(
          'SELECT COALESCE(SUM(length(payload)),0) AS bytes FROM case_cache',
        ).getSingle()).read<int>('bytes') >
        32 * 1024 * 1024) {
      await customStatement(
        'DELETE FROM case_cache WHERE rowid=(SELECT rowid FROM case_cache ORDER BY stored_at,rowid LIMIT 1)',
      );
    }
  });
  Future<void> remove(String owner, String source, String id) =>
      customStatement(
        'DELETE FROM case_cache WHERE owner=? AND source=? AND id=?',
        [owner, source, id],
      );
}
