import 'package:shared_preferences/shared_preferences.dart';

abstract interface class OnboardingCompletionCache {
  Future<bool?> read(String owner);
  Future<void> write(String owner, bool completed);
}

class PreferencesOnboardingCompletionCache
    implements OnboardingCompletionCache {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  @override
  Future<bool?> read(String owner) =>
      _preferences.getBool('onboarding_confirmed_v1:$owner');
  @override
  Future<void> write(String owner, bool completed) =>
      _preferences.setBool('onboarding_confirmed_v1:$owner', completed);
}
