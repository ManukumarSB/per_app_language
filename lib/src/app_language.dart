import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The app's own language, kept in sync with the per-app language setting in
/// Android 13+ and iOS system settings.
///
/// Call [init] once before `runApp`, then hand [locale] to your app:
///
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AppLanguage.init();
///   runApp(
///     AppLanguageBuilder(
///       builder: (context, locale) => MaterialApp(locale: locale, ...),
///     ),
///   );
/// }
///
/// // Somewhere in your settings screen:
/// AppLanguage.set(const Locale('es'));
/// AppLanguage.set(null); // back to the device language
/// ```
///
/// On platforms without a native implementation (web, desktop) the choice is
/// kept in memory for the session only.
abstract final class AppLanguage {
  static const _channel = MethodChannel('per_app_language');

  static final _locale = ValueNotifier<Locale?>(null);
  static Locale? _selected;
  static Future<void>? _init;
  static _LocaleObserver? _observer;

  /// The locale to give `MaterialApp.locale` (or `WidgetsApp.locale`).
  ///
  /// Null means "use the device language", which is what Flutter does anyway
  /// when `locale` is null.
  static ValueListenable<Locale?> get locale => _locale;

  /// The language the user picked for this app, or null if they follow the
  /// device language.
  static Locale? get selected => _selected;

  /// Whether the user follows the device language.
  static bool get followsSystem => _selected == null;

  /// Reads the saved choice from the platform and starts listening for
  /// changes made in system settings.
  ///
  /// Safe to call more than once; later calls return the first call's future.
  static Future<void> init() => _init ??= _initOnce();

  static Future<void> _initOnce() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _refresh();
    _observer = _LocaleObserver();
    WidgetsBinding.instance.addObserver(_observer!);
  }

  /// Sets the app's language. Pass null to go back to the device language.
  ///
  /// The app switches immediately. On Android 13+ the choice also appears
  /// under Settings › Apps › your app › Language, and on iOS under
  /// Settings › your app › Language.
  static Future<void> set(Locale? locale) async {
    await init();
    await _invoke<void>('setLanguage', {'tag': locale?.toLanguageTag()});
    _selected = locale;

    if (locale != null) {
      _locale.value = locale;
      return;
    }

    // Going back to the device language. Android 13+ pushes the device locale
    // to Flutter on its own. iOS only re-reads languages at launch, so for
    // the rest of this session pin the device language explicitly.
    if (_isIOS) {
      final system = await _invoke<String>('systemLanguage');
      _locale.value = system == null ? null : parseLanguageTag(system);
    } else {
      _locale.value = null;
    }
  }

  /// Opens the system screen where the user picks this app's language.
  ///
  /// Returns false where there isn't one (Android 12 and older, web,
  /// desktop) — show your own picker there. See [hasSystemSettings].
  static Future<bool> openSystemSettings() async {
    return await _invoke<bool>('openSettings') ?? false;
  }

  /// Whether the OS has a per-app language setting you can send users to.
  ///
  /// True on iOS and Android 13+. For it to list your languages, the app
  /// has to declare them — run `dart run per_app_language:setup`.
  static Future<bool> hasSystemSettings() async {
    return await _invoke<bool>('hasSystemSettings') ?? false;
  }

  static Future<void> _refresh() async {
    final tag = await _invoke<String>('getLanguage');
    final locale = tag == null ? null : parseLanguageTag(tag);
    // Mid-session resets on iOS pin the device language in _locale; don't
    // undo that just because the stored choice is (correctly) empty.
    if (locale == null && _selected == null && _locale.value != null) return;
    _selected = locale;
    _locale.value = locale;
  }

  static Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    }
  }

  static bool get _isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Forgets all state. Tests only.
  @visibleForTesting
  static void debugReset() {
    if (_observer != null) WidgetsBinding.instance.removeObserver(_observer!);
    _observer = null;
    _init = null;
    _selected = null;
    _locale.value = null;
  }
}

/// Picks up a language changed in Android 13+ system settings while the app
/// is running. (iOS relaunches the app instead.)
class _LocaleObserver with WidgetsBindingObserver {
  @override
  void didChangeLocales(List<Locale>? locales) {
    AppLanguage._refresh();
  }
}

/// Parses a BCP 47 tag like `pt-BR`, `zh-Hant-TW` or `sr_Latn` into a
/// [Locale]. Anything after the region (variants, extensions) is dropped,
/// since [Locale] has nowhere to keep it.
Locale parseLanguageTag(String tag) {
  final parts = tag.replaceAll('_', '-').split('-');
  final language = parts.first.toLowerCase();
  String? script;
  String? country;
  for (final part in parts.skip(1)) {
    if (script == null && country == null && part.length == 4) {
      script = part[0].toUpperCase() + part.substring(1).toLowerCase();
    } else if (country == null && (part.length == 2 || part.length == 3)) {
      country = part.toUpperCase();
    } else {
      break;
    }
  }
  return Locale.fromSubtags(
    languageCode: language,
    scriptCode: script,
    countryCode: country,
  );
}
