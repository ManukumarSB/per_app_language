// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get title => 'भाषा';

  @override
  String get hello => 'नमस्ते!';

  @override
  String get body => 'यह स्क्रीन हिंदी में है।';

  @override
  String get system => 'डिवाइस की भाषा';

  @override
  String get systemHint => 'आपके फ़ोन की सेटिंग के अनुसार';

  @override
  String get openSettings => 'सिस्टम सेटिंग खोलें';

  @override
  String get noSettings =>
      'इस सिस्टम में ऐप की भाषा की सेटिंग नहीं है, ऊपर दी गई सूची का उपयोग करें।';

  @override
  String get following => 'डिवाइस की भाषा का उपयोग हो रहा है';

  @override
  String chosen(String language) {
    return 'ऐप की भाषा: $language';
  }
}
