import 'support/architecture_rules.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('All mobile maps share the global tile style adapter', () {
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))) {
      final path = file.path.replaceAll('\\', '/');
      if (path.endsWith('/core/presentation/widgets/zone_map_picker.dart')) {
        continue;
      }
      expect(
        RegExp(
          r'\b(?:FlutterMap|TileLayer)\s*\(',
        ).hasMatch(file.readAsStringSync()),
        isFalse,
        reason: path,
      );
    }
    final adapter = File(
      'lib/core/presentation/widgets/zone_map_picker.dart',
    ).readAsStringSync();
    expect(adapter, contains('colorFilter: MapStyle.tileColorFilter'));
    expect(adapter, isNot(contains('this.tileColorFilter')));
  });
  test('Feature and core boundaries reject presentation/data bypasses', () {
    expect(
      crossesFeatureBoundary(
        '/lib/features/onboarding/presentation/view_models/a.dart',
        '/lib/features/auth/presentation/view_models/b.dart',
      ),
      isTrue,
    );
    expect(
      crossesFeatureBoundary(
        '/lib/features/lost_cases/presentation/a.dart',
        '/lib/features/pets/data/b.dart',
      ),
      isTrue,
    );
    expect(
      crossesFeatureBoundary(
        '/lib/core/presentation/a.dart',
        '/lib/features/pets/domain/b.dart',
      ),
      isTrue,
    );
    expect(
      crossesFeatureBoundary(
        '/lib/features/lost_cases/presentation/a.dart',
        '/lib/features/pets/domain/b.dart',
      ),
      isFalse,
    );
    expect(
      crossesFeatureBoundary(
        '/lib/app/router.dart',
        '/lib/features/pets/presentation/b.dart',
      ),
      isFalse,
    );
  });
  test('Feedback never returns inline error APIs or progress indicators', () {
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      expect(
        RegExp(
          r'volver\s+a\s+consultar',
          caseSensitive: false,
        ).hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
      expect(
        RegExp(
          r'\b(?:errorText|helperText)\s*:|\b(?:CircularProgressIndicator|LinearProgressIndicator)\b',
        ).hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
  test('Confirmation dialogs share their complete layout and route', () {
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))) {
      if (file.path
          .replaceAll('\\', '/')
          .endsWith('/core/presentation/widgets/confirm_action_dialog.dart')) {
        continue;
      }
      expect(
        RegExp(
          r'\bshow(?:General)?Dialog\s*<\s*bool\s*>',
        ).hasMatch(file.readAsStringSync()),
        false,
        reason:
            '${file.path}: delegate confirmations to confirmActionDialog instead of copying their layout.',
      );
    }
  });
  test('Report field and operation errors use the top toast', () {
    for (final feature in ['lost_cases', 'found_cases']) {
      for (final file in Directory(
        'lib/features/$feature/presentation/screens',
      ).listSync().whereType<File>()) {
        final code = file.readAsStringSync();
        expect(
          RegExp(r'\berrorText\s*:').hasMatch(code),
          false,
          reason: '${file.path}: invalid marks fields; the toast explains.',
        );
        expect(
          RegExp(r'\bText\s*\(\s*(?:case|found)FailureLabel').hasMatch(code),
          false,
          reason: '${file.path}: operation errors belong to the toast.',
        );
      }
    }
  });
  test('Pet editor field errors never render inline messages', () {
    final code = File(
      'lib/features/pets/presentation/screens/pet_editor_screen.dart',
    ).readAsStringSync();
    expect(
      RegExp(r'\berrorText\s*:').hasMatch(code),
      false,
      reason: 'ADR-016: use invalid + ShakeField and a screen-owned top toast.',
    );
  });
  test('Content loading never renders a loading text or circular indicator', () {
    final visibleLoading = RegExp(
      r'''\bText\s*\(\s*(?:\w+\s*\?\s*)?['"](?:Cargando|Preparando)\b''',
    );
    final circular = RegExp(r'\bCircularProgressIndicator\b');
    final violations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final code = file.readAsStringSync();
      if (visibleLoading.hasMatch(code) || circular.hasMatch(code)) {
        violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'Use content skeletons or retained content with top progress; accessible labels remain allowed.',
    );
  });
  test('UI loading labels never end in suspension dots', () {
    final literals = RegExp(r''''(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*"''');
    final dots = RegExp(r'(?:…|\.\.\.)\s*$');
    final violations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') ||
          !file.path.replaceAll('\\', '/').contains('/presentation/')) {
        continue;
      }
      for (final match in literals.allMatches(file.readAsStringSync())) {
        final literal = match.group(0)!;
        if (dots.hasMatch(literal.substring(1, literal.length - 1))) {
          violations.add(file.path);
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Loading uses LoadingShimmer with stable labels: $violations',
    );
  });
  test('Project UI never uses SnackBar or its display APIs', () {
    final forbidden = RegExp(
      r'\b(?:SnackBar|SnackBarAction|SnackBarBehavior|showSnackBar|hideCurrentSnackBar|removeCurrentSnackBar|snackbar)\b',
    );
    final violations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (file.path.endsWith('.dart') &&
          forbidden.hasMatch(file.readAsStringSync())) {
        violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Forbidden notification component: ${violations.join(', ')}',
    );
  });
  test('Layers respect dependency direction and SDKs stay in data sources', () {
    final violations = <String>[];
    final directives = RegExp(r'''(?:import|export|part)\s+(?!of\b)([^;]+);''');
    final uris = RegExp(r'''['"]([^'"]+)['"]''');
    final appRoot = Directory('lib').absolute.path.replaceAll('\\', '/');
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final path = file.absolute.path.replaceAll('\\', '/');
      final isDomain = path.contains('/domain/');
      final isPresentation = path.contains('/presentation/');
      final isData =
          path.contains('/data/') || path.contains('/core/data_sources/');
      final isProvider = path.contains('/providers/');
      for (final match
          in directives
              .allMatches(file.readAsStringSync())
              .expand((directive) => uris.allMatches(directive.group(1)!))) {
        final imported = match.group(1)!;
        if (imported.startsWith('dart:')) {
          if (isDomain &&
              ['dart:io', 'dart:ui', 'dart:ffi'].contains(imported)) {
            violations.add('${file.path} -> $imported');
          }
          continue;
        }
        final String target;
        if (imported.startsWith('package:flutter_application_entrehuellas/')) {
          target =
              '$appRoot/${imported.substring('package:flutter_application_entrehuellas/'.length)}';
        } else if (imported.startsWith('package:')) {
          final isDataSdk = RegExp(
            r'^package:(supabase|gotrue|postgrest|storage_client|realtime_client|http|drift|sqflite|image_picker|image/|shared_preferences|cross_file|geolocator)',
          ).hasMatch(imported);
          if (isDomain ||
              (isDataSdk &&
                  !path.contains('/data_sources/') &&
                  !path.endsWith('/app/bootstrap.dart')) ||
              (isData && imported.startsWith('package:flutter/'))) {
            violations.add('${file.path} -> $imported');
          }
          continue;
        } else {
          target = file.absolute.uri
              .resolve(imported)
              .toFilePath()
              .replaceAll('\\', '/');
        }
        if (crossesFeatureBoundary(path, target) ||
            (isDomain && !target.contains('/domain/')) ||
            (isPresentation &&
                (target.contains('/data/') ||
                    target.contains('/app/') ||
                    target.contains('/domain/repositories/'))) ||
            (isData &&
                (target.contains('/presentation/') ||
                    target.contains('/providers/') ||
                    target.contains('/app/'))) ||
            (isProvider &&
                (target.contains('/data/') ||
                    target.contains('/presentation/') ||
                    target.contains('/app/')))) {
          violations.add('${file.path} -> $imported');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
