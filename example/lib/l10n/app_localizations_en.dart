// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Language';

  @override
  String get hello => 'Hello!';

  @override
  String get body => 'This screen is in English.';

  @override
  String get system => 'Device language';

  @override
  String get systemHint => 'Follows your phone settings';

  @override
  String get openSettings => 'Open system settings';

  @override
  String get noSettings =>
      'This OS has no per-app language screen, so use the list above.';

  @override
  String get following => 'Following the device language';

  @override
  String chosen(String language) {
    return 'App language: $language';
  }
}
