// Runs against the real Kotlin/Swift code on a device or simulator:
//
//   flutter test integration_test -d <device>

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:per_app_language/per_app_language.dart';
import 'package:per_app_language_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppLanguage.set(null);
    AppLanguage.debugReset();
  });

  testWidgets('a chosen language is stored natively and survives a reload', (
    tester,
  ) async {
    await AppLanguage.set(const Locale('es'));

    // Forget everything on the Dart side and read back from the platform.
    AppLanguage.debugReset();
    await AppLanguage.init();

    expect(AppLanguage.selected, const Locale('es'));
  });

  testWidgets('going back to the device language clears the stored choice', (
    tester,
  ) async {
    await AppLanguage.set(const Locale('hi'));
    await AppLanguage.set(null);

    AppLanguage.debugReset();
    await AppLanguage.init();

    expect(AppLanguage.selected, isNull);
    expect(AppLanguage.followsSystem, isTrue);
  });

  testWidgets('the app switches language immediately', (tester) async {
    await AppLanguage.init();
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ಕನ್ನಡ'));
    await tester.pumpAndSettle();
    expect(find.text('ನಮಸ್ಕಾರ!'), findsOneWidget);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('¡Hola!'), findsOneWidget);
    expect(
      Localizations.localeOf(tester.element(find.text('¡Hola!'))),
      const Locale('es'),
    );
  });

  testWidgets('reports a system settings screen', (tester) async {
    // True on iOS and on Android 13+; the emulators we test on are both.
    expect(await AppLanguage.hasSystemSettings(), isTrue);
  });
}
