import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/queued_report.dart';
// Native Android persistence smoke. Run twice across force-stop; no account or backend.
// Uses its own database, never report_drafts.sqlite or the stored Supabase session.
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/data_sources/local_draft_database.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/repositories/local_draft_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/local_report_draft.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationSupportDirectory();
  final database = LocalDraftDatabase(
    NativeDatabase.createInBackground(
      File(path.join(directory.path, 'offline_drafts_smoke_20261023.sqlite')),
    ),
  );
  final repository = LocalDraftRepositoryImpl(database);
  var phase = 'READ';
  try {
    final saved = await repository.list('smoke-A');
    if (saved.isEmpty) {
      phase = 'WRITE';
      for (final slot in [
        'lost',
        'community-search',
        'sighting:false:target',
      ]) {
        await repository.save(
          LocalReportDraft(
            owner: 'smoke-A',
            slot: slot,
            id: 'stable-$slot',
            date: DateTime(2026, 10, 22),
            hour: 10,
            minute: null,
            latitude: -12,
            longitude: -77,
            traits: 'Evidencia café 🐾',
            photos: [
              FoundPhotoDraft(
                'photo-$slot',
                Uint8List.fromList([0, 255, 42, 1]),
              ),
            ],
          ),
        );
      }
    }
    if (phase == 'WRITE') {
      await repository.enqueue(
        LocalReportDraft(
          owner: 'smoke-A',
          slot: 'sighting:false:aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa25',
          id: 'stable-queued-command',
          frozen: true,
          instant: DateTime.utc(2026, 1, 1),
          latitude: -12,
          longitude: -77,
          comment: 'Original retained',
          photo: Uint8List.fromList([255, 216, 255, 1, 2]),
        ),
      );
      await repository.claimSubmission(
        'smoke-A',
        'stable-queued-command',
        DateTime.now(),
        manual: true,
      );
    }
    final queue = await repository.listQueue('smoke-A');
    if (queue.length != 1 ||
        queue.single.command.id != 'stable-queued-command' ||
        queue.single.command.photo![1] != 216 ||
        (phase == 'READ' && queue.single.status != SubmissionStatus.pending) ||
        (await repository.listQueue('smoke-B')).isNotEmpty) {
      throw StateError('Native queue recovery mismatch');
    }
    final drafts = await repository.list('smoke-A');
    if (drafts.length != 3 ||
        drafts.any(
          (d) =>
              d.id != 'stable-${d.slot}' ||
              d.minute != null ||
              d.hour != 10 ||
              d.traits != 'Evidencia café 🐾' ||
              d.photos.single.bytes[1] != 255,
        ) ||
        (await repository.list('smoke-B')).isNotEmpty) {
      throw StateError('Native draft persistence mismatch');
    }
    debugPrint(
      'OFFLINE_DRAFTS_SMOKE_PASS phase=$phase count=${drafts.length} accountIsolation=true evidence=true partialDate=true queueProcessRecovery=true',
    );
    await database.close();
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'SQLite Android: $phase OK\n3 borradores y fotos conservados\nCuenta B sin datos de A',
            ),
          ),
        ),
      ),
    );
  } catch (error, stack) {
    debugPrint('OFFLINE_DRAFTS_SMOKE_FAIL $error\n$stack');
    await database.close();
    rethrow;
  }
}
