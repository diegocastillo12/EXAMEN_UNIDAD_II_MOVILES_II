enum ConfigurationStatus { missing, invalid, ready }

/// Build-time public configuration. Never accepts a privileged server key.
class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.supabaseKey});

  const AppConfig.fromEnvironment()
    : supabaseUrl = const String.fromEnvironment('SUPABASE_URL'),
      supabaseKey = const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static const authRedirectUri = 'entrehuellas://login-callback/';

  final String supabaseUrl;
  final String supabaseKey;

  ConfigurationStatus get status {
    if (supabaseUrl.isEmpty && supabaseKey.isEmpty) {
      return ConfigurationStatus.missing;
    }
    final uri = Uri.tryParse(supabaseUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        !supabaseKey.startsWith('sb_publishable_') ||
        supabaseKey.length <= 'sb_publishable_'.length ||
        supabaseKey.trim() != supabaseKey) {
      return ConfigurationStatus.invalid;
    }
    return ConfigurationStatus.ready;
  }
}
