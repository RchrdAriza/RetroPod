# New app request: RetroPod

Ready-to-paste text for https://gitlab.com/fdroid/fdroiddata/-/issues
(choose "New App Request" template if available).

Submitted on 2026-08-15 as fdroiddata issue
https://gitlab.com/fdroid/fdroiddata/-/work_items/4034 (label "New App"
intended; the API did not persist the label on the work item).

---

**Application ID:** com.rchrdariza.retropod

**App name:** RetroPod

**Summary:** An iPod Classic emulator / offline music player.

**License:** MIT

**Source code:** https://github.com/RchrdAriza/RetroPod

**Issue tracker:** https://github.com/RchrdAriza/RetroPod/issues

**Changelog:** https://github.com/RchrdAriza/RetroPod/releases

**Author:** Richard Ariza

**Categories:** Music, Multimedia

**Description:** RetroPod is a faithful iPod Classic emulator that turns a
phone into a click-wheel music player. Fully offline: it plays local audio,
builds a music library from on-device files, supports playlists and
lastplayed/playcount metadata, and includes the classic cover-flow. It does
not require network permissions or an account.

**Recipe** (proposed `metadata/com.rchrdariza.retropod.yml`):

```yaml
Categories:
  - Multimedia
  - Music

License: MIT
AuthorName: Richard Ariza
AuthorWebSite: https://rchrdariza.dev
SourceCode: https://github.com/RchrdAriza/RetroPod
IssueTracker: https://github.com/RchrdAriza/RetroPod/issues
Changelog: https://github.com/RchrdAriza/RetroPod/releases

AutoName: RetroPod
RepoType: git
Repo: https://github.com/RchrdAriza/RetroPod.git

Builds:
  - versionName: 1.14.0
    versionCode: 27
    commit: 1.14.0
    output: build/app/outputs/flutter-apk/app-production-release.apk
    srclibs:
      - flutter@3.44.9
    ndk: 28.2.13676358
    prebuild:
      - export PUB_CACHE=$(pwd)/.pub-cache
      - $$flutter$$/bin/flutter config --no-analytics
      - $$flutter$$/bin/flutter pub get
      - $$flutter$$/bin/flutter gen-l10n
    scandelete:
      - .pub-cache
    build:
      - export PUB_CACHE=$(pwd)/.pub-cache
      - $$flutter$$/bin/flutter build apk --release --no-pub --flavor=production --target=lib/main.dart

AutoUpdateMode: Version
UpdateCheckMode: Tags ^\d+\.\d+\.\d+$
UpdateCheckData: pubspec.yaml|version:\s.+\+(\d+)|.|version:\s(.+)\+
CurrentVersion: 1.14.0
CurrentVersionCode: 27
```

**Notes for maintainers:**

- Flutter app; the toolchain is provided as the pinned `flutter@3.44.9`
  srclib (same version used by the GitHub Actions CI and constrained in
  `pubspec.yaml` to `>=3.44.7 <3.48.0`).
- NDK `28.2.13676358` matches `android/app/build.gradle.kts`.
- `prebuild` runs `flutter pub get` and `flutter gen-l10n` because the
  generated localizations in `lib/l10n/generated` are not committed; the
  build step reuses the prebuilt pub cache with `--no-pub`.
- Two dependencies are pulled from git
  (`adeeteya/Disable-Battery-Optimizations` and
  `adeeteya/on_audio_query` with `path: packages/on_audio_query`);
  `pubspec.lock` pins their commits.
- The production flavor APK has **no INTERNET permission**.
- Verified locally with `fdroid readmeta` (exit 0) and
  `fdroid build --test` twice on tag `1.14.0`: both unsigned APK contents
  are byte-identical (Dart AOT snapshot only differs by the embedded
  absolute build path, which is constant on the F-Droid build server).
- The build server release should be roughly reproducible with the CI
  reference (local build of tag 1.13.0, SHA-256
  `46eddb0a485fb814c06a5b08ed613de08df34073445dc85e6b14dff5b83d30b1`),
  modulo the absolute-path caveat above.

**Possible review flags:**

- The app asks the user to disable battery optimization (via the
  `disable_battery_optimization` git dependency); motivation: background
  audio playback in a music player.
- The iPod icons come from Flaticon (free with attribution), which F-Droid
  may tag with the `NonFreeAssets` anti-feature (a tag, not a blocker).
- First Android APK is ~89 MB (media_kit, on_audio_query, image
  thumbnails); a `--split-per-abi` split is planned after inclusion.