import 'package:flutter/widgets.dart';

import 'app_language.dart';

/// Rebuilds with the current [AppLanguage.locale].
///
/// Wrap your `MaterialApp` (or `CupertinoApp`, `WidgetsApp`) and pass the
/// locale through:
///
/// ```dart
/// AppLanguageBuilder(
///   builder: (context, locale) => MaterialApp(
///     locale: locale,
///     supportedLocales: AppLocalizations.supportedLocales,
///     localizationsDelegates: AppLocalizations.localizationsDelegates,
///     home: const HomePage(),
///   ),
/// )
/// ```
///
/// Calls [AppLanguage.init] if you haven't. Awaiting it before `runApp` is
/// still better: otherwise the first frame uses the device language and then
/// switches.
class AppLanguageBuilder extends StatefulWidget {
  /// Creates a widget that rebuilds when the app language changes.
  const AppLanguageBuilder({super.key, required this.builder});

  /// Builds the app with the locale to use, or null for the device language.
  final Widget Function(BuildContext context, Locale? locale) builder;

  @override
  State<AppLanguageBuilder> createState() => _AppLanguageBuilderState();
}

class _AppLanguageBuilderState extends State<AppLanguageBuilder> {
  @override
  void initState() {
    super.initState();
    AppLanguage.init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: AppLanguage.locale,
      builder: (context, locale, _) => widget.builder(context, locale),
    );
  }
}
