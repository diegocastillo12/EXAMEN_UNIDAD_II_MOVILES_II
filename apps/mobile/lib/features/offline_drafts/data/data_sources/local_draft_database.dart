import 'package:drift/drift.dart';

/// Schema 2: private drafts and durable, claimed submission commands.
/// No file references to the image picker's temporary directory survive here.
class LocalDraftDatabase extends GeneratedDatabase {
  LocalDraftDatabase(super.executor);
  @override
  int get schemaVersion => 2;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      await customStatement('''CREATE TABLE report_drafts (
      owner TEXT NOT NULL, slot TEXT NOT NULL, id TEXT NOT NULL,
      payload TEXT NOT NULL, PRIMARY KEY(owner, slot)
    )''');
      await _createQueue();
    },
    onUpgrade: (_, from, to) async {
      if (from < 2) await _createQueue();
    },
  );

  Future<void> _createQueue() =>
      customStatement('''CREATE TABLE submission_queue (
    owner TEXT NOT NULL, id TEXT NOT NULL, payload TEXT NOT NULL, fingerprint TEXT NOT NULL,
    state TEXT NOT NULL CHECK(state IN ('pending','sending','failed','published')),
    attempts INTEGER NOT NULL DEFAULT 0 CHECK(attempts >= 0),
    created_at INTEGER NOT NULL, next_attempt_at INTEGER NOT NULL,
    issue TEXT, receipt TEXT, process TEXT, claim TEXT,
    PRIMARY KEY(owner,id), CHECK((state = 'published') = (receipt IS NOT NULL))
  )''');

  Future<void> recoverQueue(String owner, String process) => customStatement(
    "UPDATE submission_queue SET state='pending', claim=NULL WHERE owner=? AND state='sending' AND (process IS NULL OR process<>?)",
    [owner, process],
  );
  Future<String?> cancelQueue(String owner, String id) => transaction(() async {
    final entry = await queueRow(owner, id);
    if (entry == null) return null;
    if (['sending', 'published'].contains(entry['state'])) {
      return entry['state'] as String;
    }
    await customStatement(
      'DELETE FROM submission_queue WHERE owner=? AND id=?',
      [owner, id],
    );
    return null;
  });
  Future<Map<String, dynamic>?> queueRow(String owner, String id) async =>
      (await customSelect(
        'SELECT * FROM submission_queue WHERE owner=? AND id=?',
        variables: [Variable(owner), Variable(id)],
      ).getSingleOrNull())?.data;
  Future<List<Map<String, dynamic>>> queueRows(
    String owner,
  ) async => (await customSelect(
    'SELECT * FROM submission_queue WHERE owner=? ORDER BY created_at DESC, id',
    variables: [Variable(owner)],
  ).get()).map((r) => r.data).toList();

  /// A transaction binds a stable ID to exactly one command across repository instances.
  Future<Map<String, dynamic>> enqueueSubmission(
    String owner,
    String id,
    String payload,
    String fingerprint,
    int now,
    bool resolveRejected,
  ) => transaction(() async {
    final old = await queueRow(owner, id);
    if (old == null) {
      await customStatement(
        '''INSERT INTO submission_queue(owner,id,payload,fingerprint,state,created_at,next_attempt_at)
        VALUES(?,?,?,?,'pending',?,?)''',
        [owner, id, payload, fingerprint, now, now],
      );
    } else if (old['fingerprint'] != fingerprint) {
      if (!resolveRejected ||
          old['state'] != 'failed' ||
          !['invalid', 'photo'].contains(old['issue'])) {
        throw const QueuePayloadConflict();
      }
      await customStatement(
        "UPDATE submission_queue SET payload=?, fingerprint=?,state='pending',issue=NULL,claim=NULL,next_attempt_at=? WHERE owner=? AND id=?",
        [payload, fingerprint, now, owner, id],
      );
    }
    return (await queueRow(owner, id))!;
  });
  Future<Map<String, dynamic>?> claimQueue(
    String owner,
    String id,
    String process,
    String claim,
    int now,
    bool manual,
  ) => transaction(() async {
    await recoverQueue(owner, process);
    final changed = await customUpdate(
      """UPDATE submission_queue SET state='sending',attempts=attempts+1,
        claim=?,process=?,issue=NULL WHERE owner=? AND id=? AND
        ((state='pending' AND (next_attempt_at<=? OR ?=1)) OR (state='failed' AND ?=1))""",
      variables: [
        Variable(claim),
        Variable(process),
        Variable(owner),
        Variable(id),
        Variable(now),
        Variable(manual ? 1 : 0),
        Variable(manual ? 1 : 0),
      ],
    );
    return changed == 1 ? queueRow(owner, id) : null;
  });
  Future<void> completeQueue(
    String owner,
    String id,
    String claim,
    String receipt,
    String redactedPayload,
  ) async {
    final changed = await customUpdate(
      "UPDATE submission_queue SET state='published',receipt=?,payload=?,issue=NULL,claim=NULL WHERE owner=? AND id=? AND state='sending' AND claim=?",
      variables: [
        Variable(receipt),
        Variable(redactedPayload),
        Variable(owner),
        Variable(id),
        Variable(claim),
      ],
    );
    if (changed != 1) throw StateError('Submission claim no longer current');
  }

  Future<void> failQueue(
    String owner,
    String id,
    String claim,
    String state,
    String issue,
    int nextAttemptAt,
  ) => customStatement(
    "UPDATE submission_queue SET state=?,issue=?,next_attempt_at=?,claim=NULL WHERE owner=? AND id=? AND state='sending' AND claim=?",
    [state, issue, nextAttemptAt, owner, id, claim],
  );

  Future<String?> readPayload(String owner, String slot) async {
    final row = await customSelect(
      'SELECT payload FROM report_drafts WHERE owner = ? AND slot = ?',
      variables: [Variable(owner), Variable(slot)],
    ).getSingleOrNull();
    return row?.read<String>('payload');
  }

  Future<List<String>> listPayloads(String owner) async => (await customSelect(
    'SELECT payload FROM report_drafts WHERE owner = ? ORDER BY slot',
    variables: [Variable(owner)],
  ).get()).map((row) => row.read<String>('payload')).toList();

  Future<void> put(
    String owner,
    String slot,
    String id,
    String payload,
  ) => customStatement(
    '''INSERT INTO report_drafts (owner, slot, id, payload) VALUES (?, ?, ?, ?)
       ON CONFLICT(owner, slot) DO UPDATE SET id = excluded.id, payload = excluded.payload''',
    [owner, slot, id, payload],
  );
  Future<void> remove(String owner, String slot, String id) => customStatement(
    'DELETE FROM report_drafts WHERE owner = ? AND slot = ? AND id = ?',
    [owner, slot, id],
  );
}

class QueuePayloadConflict implements Exception {
  const QueuePayloadConflict();
}
