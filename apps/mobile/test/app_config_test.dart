import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/bootstrap.dart';
import 'package:flutter_application_entrehuellas/core/config/app_config.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';

void main() {
  test('Empty configuration starts without initializing Supabase', () async {
    const config = AppConfig(supabaseUrl: '', supabaseKey: '');
    final app = await bootstrapApp(config);
    expect(app.state.status, StartupStatus.missingConfiguration);
    expect(await app.authRepository.watchSession().first, isNull);
  });

  test('HTTPS URL and publishable key are accepted', () {
    const config = AppConfig(
      supabaseUrl: 'https://project.supabase.co',
      supabaseKey: 'sb_publishable_test',
    );
    expect(config.status, ConfigurationStatus.ready);
  });

  for (final entry in {
    'partial configuration': ('https://project.supabase.co', ''),
    'HTTP endpoint': ('http://project.supabase.co', 'sb_publishable_test'),
    'URL credentials': (
      'https://user:pass@project.supabase.co',
      'sb_publishable_test',
    ),
    'query in endpoint': (
      'https://project.supabase.co?token=value',
      'sb_publishable_test',
    ),
    'server key': ('https://project.supabase.co', 'sb_secret_test'),
    'legacy JWT': ('https://project.supabase.co', 'eyJhbGciOiJIUzI1NiJ9'),
  }.entries) {
    test('Rejects ${entry.key} without initializing Supabase', () async {
      final config = AppConfig(
        supabaseUrl: entry.value.$1,
        supabaseKey: entry.value.$2,
      );
      final app = await bootstrapApp(config);
      expect(app.state.status, StartupStatus.invalidConfiguration);
      expect(await app.authRepository.watchSession().first, isNull);
    });
  }
}
