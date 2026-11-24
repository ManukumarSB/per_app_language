// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get title => 'ಭಾಷೆ';

  @override
  String get hello => 'ನಮಸ್ಕಾರ!';

  @override
  String get body => 'ಈ ಪರದೆ ಕನ್ನಡದಲ್ಲಿದೆ.';

  @override
  String get system => 'ಸಾಧನದ ಭಾಷೆ';

  @override
  String get systemHint => 'ನಿಮ್ಮ ಫೋನ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಅನುಸರಿಸುತ್ತದೆ';

  @override
  String get openSettings => 'ಸಿಸ್ಟಮ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get noSettings =>
      'ಈ ಸಿಸ್ಟಮ್‌ನಲ್ಲಿ ಆ್ಯಪ್ ಭಾಷೆಯ ಸೆಟ್ಟಿಂಗ್ ಇಲ್ಲ, ಮೇಲಿನ ಪಟ್ಟಿಯನ್ನು ಬಳಸಿ.';

  @override
  String get following => 'ಸಾಧನದ ಭಾಷೆಯನ್ನು ಬಳಸಲಾಗುತ್ತಿದೆ';

  @override
  String chosen(String language) {
    return 'ಆ್ಯಪ್ ಭಾಷೆ: $language';
  }
}
