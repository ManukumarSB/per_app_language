// Flutter 3.47 moved Material to package:material_ui, but that package needs
// Flutter >=3.47 and we still support 3.32. Switch once the floor gets there.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:per_app_language/per_app_language.dart';

import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read the saved language before the first frame, so the app doesn't
  // start in the device language and then flip.
  await AppLanguage.init();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLanguageBuilder(
      builder: (context, locale) => MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        onGenerateTitle: (context) => AppLocalizations.of(context).title,
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark,
        ),
        home: const LanguagePage(),
      ),
    );
  }
}

/// Each language in its own script, so people can find theirs.
const _languages = {
  'en': 'English',
  'es': 'Español',
  'hi': 'हिन्दी',
  'kn': 'ಕನ್ನಡ',
};

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late final Future<bool> _hasSystemSettings = AppLanguage.hasSystemSettings();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selected = AppLanguage.selected?.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.title)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.hello, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(l10n.body),
                  const SizedBox(height: 12),
                  Text(
                    selected == null
                        ? l10n.following
                        : l10n.chosen(_languages[selected] ?? selected),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          RadioListTile<String?>(
            value: null,
            groupValue: selected,
            title: Text(l10n.system),
            subtitle: Text(l10n.systemHint),
            onChanged: (_) => AppLanguage.set(null),
          ),
          const Divider(indent: 16, endIndent: 16),
          for (final entry in _languages.entries)
            RadioListTile<String?>(
              value: entry.key,
              groupValue: selected,
              title: Text(entry.value),
              onChanged: (code) => AppLanguage.set(Locale(code!)),
            ),
          const SizedBox(height: 16),
          FutureBuilder<bool>(
            future: _hasSystemSettings,
            builder: (context, snapshot) {
              if (snapshot.data != true) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.noSettings,
                    style: theme.textTheme.bodySmall,
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: AppLanguage.openSystemSettings,
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(l10n.openSettings),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
