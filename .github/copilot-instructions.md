# Project Guidelines

## Code Style
- Use Dart and Flutter defaults enforced by `flutter_lints` in `analysis_options.yaml`.
- Keep code formatted with `dart format` (or IDE format-on-save) and preserve trailing commas in widget trees.
- Prefer small, composable widgets over large build methods as screens grow.
- Use `const` constructors/widgets when values are compile-time constants.

## Architecture
- Current app structure is scaffold-level:
  - App entry point and root widgets are in `lib/main.dart`.
  - Widget tests are in `test/widget_test.dart`.
- Keep `lib/main.dart` focused on app bootstrap. When adding features, move feature UI and logic into dedicated files under `lib/`.
- Maintain clear separation between UI code (widgets) and non-UI logic as the project grows.

## Build and Test
- Install dependencies: `flutter pub get`
- Static analysis: `flutter analyze`
- Run tests: `flutter test`
- Run a specific test: `flutter test test/widget_test.dart`
- Run app on Windows: `flutter run -d windows`
- Run app on web: `flutter run -d chrome`
- Build release artifacts as needed:
  - `flutter build windows`
  - `flutter build apk`
  - `flutter build ios` (macOS only)

## Conventions
- This is a private app (`publish_to: none` in `pubspec.yaml`), not intended for pub.dev publishing.
- The app currently uses Material theming (`ThemeData` with `ColorScheme.fromSeed`). Keep visual changes consistent with this unless a redesign is requested.
- Prefer widget tests using `flutter_test` + `WidgetTester` patterns shown in `test/widget_test.dart`.
- If platform identifiers are changed for release, update all platform-specific config files consistently (Android, iOS, desktop targets).

## References
- Project overview: [README.md](README.md)
- Flutter docs: https://docs.flutter.dev