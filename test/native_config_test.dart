import 'package:flutter_test/flutter_test.dart';
import 'package:per_app_language/src/setup/native_config.dart';

// What `flutter create` generates, trimmed.
const _manifest =
    '''<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="example"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity android:name=".MainActivity"/>
    </application>
</manifest>
''';

const _plist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>Example</string>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
</dict>
</plist>
''';

void main() {
  group('localeOfArb', () {
    test('prefers @@locale', () {
      expect(
        localeOfArb('app_en.arb', '{"@@locale": "pt_BR", "hi": "Oi"}'),
        'pt-BR',
      );
    });

    test('falls back to the file name', () {
      expect(localeOfArb('app_en.arb', '{}'), 'en');
      expect(localeOfArb('intl_pt_BR.arb', '{}'), 'pt-BR');
      expect(localeOfArb('strings_zh_Hant_TW.arb', '{}'), 'zh-Hant-TW');
      expect(localeOfArb('app_es_419.arb', '{}'), 'es-419');
    });

    test('normalizes case', () {
      expect(localeOfArb('x.arb', '{"@@locale": "ZH_hant"}'), 'zh-Hant');
    });

    test('returns null when it cannot tell', () {
      expect(localeOfArb('strings.arb', '{}'), isNull);
    });
  });

  group('localesConfigXml', () {
    test('lists every locale', () {
      final xml = localesConfigXml(['en', 'es', 'pt-BR']);

      expect(xml, contains('<locale android:name="en"/>'));
      expect(xml, contains('<locale android:name="es"/>'));
      expect(xml, contains('<locale android:name="pt-BR"/>'));
      expect(xml, startsWith('<?xml'));
      expect(xml, contains('<locale-config xmlns:android='));
    });
  });

  group('patchAndroidManifest', () {
    test('adds localeConfig on its own line, matching indentation', () {
      final patched = patchAndroidManifest(_manifest);

      expect(
        patched,
        contains(
          '<application\n        android:localeConfig="@xml/locales_config"\n        android:label="example"',
        ),
      );
    });

    test('works when attributes are on the same line', () {
      final patched = patchAndroidManifest(
        '<manifest><application android:label="x"></application></manifest>',
      );

      expect(
        patched,
        '<manifest><application android:localeConfig="@xml/locales_config" android:label="x"></application></manifest>',
      );
    });

    test('is idempotent', () {
      final once = patchAndroidManifest(_manifest);
      expect(patchAndroidManifest(once), once);
    });

    test('leaves an existing localeConfig alone', () {
      final custom = _manifest.replaceFirst(
        '<application',
        '<application android:localeConfig="@xml/mine"',
      );
      expect(patchAndroidManifest(custom), custom);
    });

    test('rejects a manifest without <application>', () {
      expect(() => patchAndroidManifest('<manifest/>'), throwsFormatException);
    });
  });

  group('patchInfoPlist', () {
    test('adds CFBundleLocalizations with underscores', () {
      final patched = patchInfoPlist(_plist, ['en', 'pt-BR']);

      expect(
        patched,
        contains(
          '\t<key>CFBundleLocalizations</key>\n\t<array>\n\t\t<string>en</string>\n\t\t<string>pt_BR</string>\n\t</array>\n</dict>',
        ),
      );
    });

    test('replaces an existing list instead of adding a second', () {
      final once = patchInfoPlist(_plist, ['en', 'fr']);
      final twice = patchInfoPlist(once, ['en', 'es', 'hi']);

      expect(RegExp('CFBundleLocalizations').allMatches(twice), hasLength(1));
      expect(twice, contains('<string>hi</string>'));
      expect(twice, isNot(contains('<string>fr</string>')));
    });

    test('is idempotent', () {
      final once = patchInfoPlist(_plist, ['en', 'es']);
      expect(patchInfoPlist(once, ['en', 'es']), once);
    });

    test('keeps the rest of the plist untouched', () {
      final patched = patchInfoPlist(_plist, ['en', 'es']);
      expect(
        patched,
        contains('<key>CFBundleDisplayName</key>\n\t<string>Example</string>'),
      );
      expect(patched, endsWith('</dict>\n</plist>\n'));
    });

    test('rejects a plist without <dict>', () {
      expect(() => patchInfoPlist('<plist/>', ['en']), throwsFormatException);
    });
  });
}
