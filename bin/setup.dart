// Writes the native config that makes your languages appear in Android 13+
// and iOS system settings.
//
//   dart run per_app_language:setup              # locales from your .arb files
//   dart run per_app_language:setup --locales en,es,pt-BR
//   dart run per_app_language:setup --check      # exit 1 if out of date (CI)
//   dart run per_app_language:setup --dry-run    # show what would change

import 'dart:io';

import 'package:per_app_language/src/setup/native_config.dart';

void main(List<String> args) {
  if (args.contains('-h') || args.contains('--help')) {
    stdout.writeln(_usage);
    return;
  }
  final check = args.contains('--check');
  final dryRun = args.contains('--dry-run') || check;

  if (!File('pubspec.yaml').existsSync()) {
    _fail(
      'Run this from the root of your Flutter app (where pubspec.yaml is).',
    );
  }

  final locales = _locales(args);
  if (locales.length < 2) {
    stdout.writeln(
      'Found ${locales.length} locale(s): ${locales.join(', ')}.\n'
      'Per-app language only makes sense with two or more; nothing to do.',
    );
    return;
  }
  stdout.writeln('Locales: ${locales.join(', ')}\n');

  final changes = <String, String>{};

  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (manifest.existsSync()) {
    changes['android/app/src/main/res/xml/locales_config.xml'] =
        localesConfigXml(locales);
    changes[manifest.path] = patchAndroidManifest(manifest.readAsStringSync());
  } else {
    stdout.writeln('No android/ folder, skipping Android.');
  }

  final plist = File('ios/Runner/Info.plist');
  if (plist.existsSync()) {
    changes[plist.path] = patchInfoPlist(plist.readAsStringSync(), locales);
  } else {
    stdout.writeln('No ios/Runner/Info.plist, skipping iOS.');
  }

  var outdated = 0;
  changes.forEach((path, contents) {
    final file = File(path);
    final current = file.existsSync() ? file.readAsStringSync() : null;
    if (current == contents) {
      stdout.writeln('  up to date  $path');
      return;
    }
    outdated++;
    stdout.writeln('  ${current == null ? 'create' : 'update'}      $path');
    if (!dryRun) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(contents);
    }
  });

  if (check && outdated > 0) {
    _fail(
      '\n$outdated file(s) out of date. Run: dart run per_app_language:setup',
    );
  }
  if (dryRun && !check && outdated > 0) {
    stdout.writeln('\nDry run, nothing written.');
  }
}

List<String> _locales(List<String> args) {
  final i = args.indexOf('--locales');
  if (i != -1) {
    if (i + 1 >= args.length) {
      _fail('--locales needs a value, e.g. --locales en,es');
    }
    return args[i + 1]
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  final dir = Directory(_arbDir());
  if (!dir.existsSync()) {
    _fail(
      'No ${dir.path}/ found. Pass --locales en,es,... or set arb-dir in l10n.yaml.',
    );
  }
  final found = <String>{};
  for (final file in dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.arb'),
  )) {
    final locale = localeOfArb(
      file.uri.pathSegments.last,
      file.readAsStringSync(),
    );
    if (locale != null) found.add(locale);
  }
  return found.toList()..sort();
}

/// `arb-dir` from l10n.yaml, falling back to Flutter's default.
String _arbDir() {
  final l10n = File('l10n.yaml');
  if (l10n.existsSync()) {
    final match = RegExp(
      r'^arb-dir:\s*(\S+)',
      multiLine: true,
    ).firstMatch(l10n.readAsStringSync());
    if (match != null) return match.group(1)!;
  }
  return 'lib/l10n';
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}

const _usage = '''
Writes the native config that lists your app's languages in Android 13+ and
iOS system settings.

Usage: dart run per_app_language:setup [options]

  --locales en,es,pt-BR   Use these instead of reading your .arb files
  --dry-run               Show what would change without writing
  --check                 Exit with code 1 if anything is out of date
  -h, --help              Show this help

Files touched:
  android/app/src/main/res/xml/locales_config.xml   (created)
  android/app/src/main/AndroidManifest.xml          (android:localeConfig)
  ios/Runner/Info.plist                             (CFBundleLocalizations)
''';
