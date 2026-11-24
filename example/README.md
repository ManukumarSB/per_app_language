# per_app_language example

A small app localized in English, Spanish, Hindi and Kannada with Flutter's
`gen-l10n`. Pick a language in the app or in the phone's settings and watch
the other follow.

```sh
dart run per_app_language:setup   # already done here; shows how it's used
flutter run
```

`integration_test/` runs against the real Kotlin and Swift code:

```sh
flutter test integration_test -d <device>
```
