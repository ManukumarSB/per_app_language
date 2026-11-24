
import 'per_app_language_platform_interface.dart';

class PerAppLanguage {
  Future<String?> getPlatformVersion() {
    return PerAppLanguagePlatform.instance.getPlatformVersion();
  }
}
