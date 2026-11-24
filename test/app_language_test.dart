import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:per_app_language/per_app_language.dart';

const _channel = MethodChannel('per_app_language');

/// A stand-in for the native side, with the same behaviour the Kotlin and
/// Swift code have.
class _FakePlatform {
  String? stored;
  String system = 'en-US';
  bool hasSettings = true;
  bool settingsOpened = false;
  final calls = <MethodCall>[];

  Future<Object?> handle(MethodCall call) async {
    calls.add(call);
    switch (call.method) {
      case 'getLanguage':
        return stored;
      case 'setLanguage':
        stored = (call.arguments as Map)['tag'] as String?;
        return null;
      case 'systemLanguage':
        return system;
      case 'openSettings':
        settingsOpened = hasSettings;
        return hasSettings;
      case 'hasSystemSettings':
        return hasSettings;
    }
    throw MissingPluginException();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakePlatform platform;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    platform = _FakePlatform();
    messenger.setMockMethodCallHandler(_channel, platform.handle);
  });

  tearDown(() {
    AppLanguage.debugReset();
    messenger.setMockMethodCallHandler(_channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('init', () {
    test('follows the system when nothing is saved', () async {
      await AppLanguage.init();

      expect(AppLanguage.selected, isNull);
      expect(AppLanguage.followsSystem, isTrue);
      expect(AppLanguage.locale.value, isNull);
    });

    test('picks up a saved language', () async {
      platform.stored = 'pt-BR';

      await AppLanguage.init();

      expect(AppLanguage.selected, const Locale('pt', 'BR'));
      expect(AppLanguage.locale.value, const Locale('pt', 'BR'));
    });

    test('only talks to the platform once', () async {
      await Future.wait([
        AppLanguage.init(),
        AppLanguage.init(),
        AppLanguage.init(),
      ]);

      expect(
        platform.calls.where((c) => c.method == 'getLanguage'),
        hasLength(1),
      );
    });
  });

  group('set', () {
    test('saves the language and switches immediately', () async {
      await AppLanguage.set(const Locale('es'));

      expect(platform.stored, 'es');
      expect(AppLanguage.selected, const Locale('es'));
      expect(AppLanguage.locale.value, const Locale('es'));
    });

    test('sends a full BCP 47 tag', () async {
      await AppLanguage.set(
        const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
      );

      expect(platform.stored, 'zh-Hant-TW');
    });

    test('null goes back to the device language on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      platform.stored = 'fr';
      await AppLanguage.init();

      await AppLanguage.set(null);

      expect(platform.stored, isNull);
      expect(AppLanguage.followsSystem, isTrue);
      // Android 13+ sends the device locale to Flutter by itself.
      expect(AppLanguage.locale.value, isNull);
    });

    test('null on iOS pins the device language for the session', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      platform
        ..stored = 'fr'
        ..system = 'en-GB';
      await AppLanguage.init();

      await AppLanguage.set(null);

      expect(platform.stored, isNull);
      expect(AppLanguage.followsSystem, isTrue);
      // Flutter's locales still reflect the launch-time French on iOS.
      expect(AppLanguage.locale.value, const Locale('en', 'GB'));
    });

    test('notifies listeners', () async {
      final seen = <Locale?>[];
      AppLanguage.locale.addListener(() => seen.add(AppLanguage.locale.value));

      await AppLanguage.set(const Locale('hi'));
      await AppLanguage.set(const Locale('kn'));

      expect(seen, const [Locale('hi'), Locale('kn')]);
    });
  });

  group('system settings', () {
    test('a change made in Android settings reaches the app', () async {
      await AppLanguage.init();

      // User picks German in Settings while the app is running: Android
      // stores it and Flutter gets a locale change.
      platform.stored = 'de';
      WidgetsBinding.instance.handleLocaleChanged();
      await pumpEventQueue();

      expect(AppLanguage.selected, const Locale('de'));
      expect(AppLanguage.locale.value, const Locale('de'));
    });

    test('openSystemSettings reports whether a screen opened', () async {
      expect(await AppLanguage.openSystemSettings(), isTrue);
      expect(platform.settingsOpened, isTrue);

      platform.hasSettings = false;
      expect(await AppLanguage.openSystemSettings(), isFalse);
      expect(await AppLanguage.hasSystemSettings(), isFalse);
    });
  });

  group('without a native implementation', () {
    setUp(() => messenger.setMockMethodCallHandler(_channel, null));

    test('keeps the choice in memory', () async {
      await AppLanguage.init();
      await AppLanguage.set(const Locale('ja'));

      expect(AppLanguage.locale.value, const Locale('ja'));
      expect(await AppLanguage.openSystemSettings(), isFalse);
      expect(await AppLanguage.hasSystemSettings(), isFalse);
    });
  });

  group('AppLanguageBuilder', () {
    testWidgets('rebuilds with the new locale', (tester) async {
      final built = <Locale?>[];
      await tester.pumpWidget(
        AppLanguageBuilder(
          builder: (context, locale) {
            built.add(locale);
            return const SizedBox();
          },
        ),
      );
      await tester.runAsync(() => AppLanguage.set(const Locale('ta')));
      await tester.pump();

      expect(built, [null, const Locale('ta')]);
    });
  });

  group('parseLanguageTag', () {
    final cases = {
      'en': const Locale('en'),
      'pt-BR': const Locale('pt', 'BR'),
      'pt_BR': const Locale('pt', 'BR'),
      'EN-us': const Locale('en', 'US'),
      'zh-Hant': const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
      ),
      'zh-hant-tw': const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
        countryCode: 'TW',
      ),
      'es-419': const Locale('es', '419'),
      'sr-Latn-RS-x-private': const Locale.fromSubtags(
        languageCode: 'sr',
        scriptCode: 'Latn',
        countryCode: 'RS',
      ),
    };
    cases.forEach((tag, locale) {
      test(tag, () => expect(parseLanguageTag(tag), locale));
    });

    test('round-trips with Locale.toLanguageTag', () {
      for (final locale in cases.values) {
        expect(parseLanguageTag(locale.toLanguageTag()), locale);
      }
    });
  });
}
