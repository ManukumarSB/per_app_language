// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get title => 'Idioma';

  @override
  String get hello => '¡Hola!';

  @override
  String get body => 'Esta pantalla está en español.';

  @override
  String get system => 'Idioma del dispositivo';

  @override
  String get systemHint => 'Sigue los ajustes de tu teléfono';

  @override
  String get openSettings => 'Abrir ajustes del sistema';

  @override
  String get noSettings =>
      'Este sistema no tiene ajustes de idioma por app; usa la lista de arriba.';

  @override
  String get following => 'Usando el idioma del dispositivo';

  @override
  String chosen(String language) {
    return 'Idioma de la app: $language';
  }
}
