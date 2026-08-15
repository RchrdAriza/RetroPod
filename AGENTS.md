# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds app code: `core/` for shared services, `features/` for UI flows, `hive/` for adapters, and entry points in `main.dart`, `main_development.dart`, and `retropod_app.dart`.
- Platform scaffolding lives in `android/`, `ios/`, `linux/`, `macos/`, `windows/`, and `web/`; assets and fonts sit in `assets/`; automation scripts live in `fastlane/` and `scripts/`.
- Tests mirror production code under `test/unit_tests/` and `test/widget_tests/`, with reusable fixtures in `test/test_files/` and caches in `test/cache/`.

## Build, Test, and Development Commands
- `flutter pub get --suppress-analytics` refreshes dependencies after any `pubspec.yaml` change.
- `flutter pub run build_runner build --delete-conflicting-outputs` regenerates Hive TypeAdapters before building.
- `flutter gen-l10n` keeps `lib/l10n/` synced with `l10n.yaml`.
- `flutter analyze --suppress-analytics` or `dart run custom_lint` must be clean prior to committing.
- Format with `flutter format --set-exit-if-changed lib/ test/`.
- `flutter test --no-pub --coverage --suppress-analytics` is the required test invocation; upload `coverage/lcov.info` when CI or reviewers ask.
- Release builds are standardized through Fastlane, e.g. `bundle exec fastlane build_flutter_app type:apk` (swap `ipa`, `appbundle`, etc. as needed).

## Coding Style & Naming Conventions
- Respect `analysis_options.yaml`: declare return types, prefer `const`, keep package imports absolute, and stay ≤80 columns.
- Use `snake_case.dart` filenames, `UpperCamelCase` for classes, and suffix Riverpod notifiers/controllers (`PlaybackController`, `LibraryNotifier`) inside `lib/features/`.
- Factor reusable UI into `lib/core/widgets/`, include trailing commas, and avoid relative imports (`../`) entirely.
- Do not use emojis anywhere (code, docs, commit messages, chat): write plain text only.

## Testing Guidelines
- Store pure logic specs in `test/unit_tests/` and widget scenarios in `test/widget_tests/`, mirroring the folder layout under `lib/features/`.
- Name every file `_test.dart`, group cases by behavior (`group('cover_flow', ...)`), and prefer golden tests for UI regressions.
- Maintain coverage by extending suites whenever playback, persistence, or routing code changes; reuse fixtures from `test/test_files/` instead of adding new binaries.

## Commit & Pull Request Guidelines
- Write present-tense commits referencing issues (`fixes #51`) when applicable; no emojis or emoji prefixes in commit messages.
- Complete the checklist in `pull_request_template.md`, note platform verification (Android/Windows/Web), and include before/after screenshots for UI work.
- Summarize any Fastlane or build-runner commands you ran so reviewers can reproduce the environment.

## Security & Configuration Tips
- Keep store credentials and service accounts outside the repo; point Fastlane to them via environment variables like `GOOGLE_SERVICE_ACCOUNT_JSON_PATH`.
- When bumping dependencies or assets, cross-check platform builds and update `CHANGELOG.md` alongside the code change.
