# Submitting RetroPod to the official F-Droid store

## Steps taken in this repository

- Relicensed to MIT; original ClassiPod code kept under BSD-4-Clause in
  `LICENSE-CLASSIPOD`, with attribution in `NOTICE`.
- Replaced all proprietary assets (Helvetica font) with free ones and
  documented every asset license in `ASSETS-LICENSES.md`.
- Made Android builds reproducible and added `scripts/verify_reproducible_build.sh`.
- Rewrote Terms and Privacy Policy for the offline, open source app, and
  removed the "Donate" feature and upstream donation link.
- Pinned the Flutter toolchain in CI to 3.44.9 (bumping the pubspec
  constraint allows that version, `>=3.44.7 <3.48.0`), matching the pinned
  `flutter@3.44.9` srclib in the F-Droid recipe
  (`fdroid/com.rchrdariza.retropod.yml`).

## The recipe (for fdroiddata)

Copy `fdroid/com.rchrdariza.retropod.yml` into the fdroiddata repository as

    metadata/com.rchrdariza.retropod.yml

For the first build it references commit `6bbcaf0` (versionCode 26). Note:
the `1.13.0` tag (`1974434`) predates the F-Droid preparation work (it still
had the BSD license and Helvetica fonts), so the recipe points at the remote
commit that contains MIT + LiberationSans + no donate. The APK output path is
`build/app/outputs/flutter-apk/app-production-release.apk`. The recipe:

- Provides Flutter as a srclib pinned to 3.44.9.
- Requires NDK 28.2.13676358 (same as `android/app/build.gradle.kts`).
- Runs `flutter pub get` and `flutter gen-l10n` in `prebuild` (the generated
  localizations in `lib/l10n/generated` are not committed).
- Builds with `--no-pub` against the prebuilt pub cache for reproducibility.

## Reference build / binary transparency

`docs/fdroid/reference-build-1.13.0.sha256` stores the SHA-256 of the APK
built twice with Flutter 3.44.9 from tag 1.13.0:

    46eddb0a485fb814c06a5b08ed613de08df34073445dc85e6b14dff5b83d30b1

The F-Droid build should produce the same hash when built with the pinned
toolchain and without `--obfuscate`/`--split-debug-info`.

Caveat verified on 15/08/2026 with `fdroid build --test`: two fdroid builds
of commit `6bbcaf0` are byte-identical (unsigned tree hash
`bfb9308f59603f13c08c3e8040b1f5ab1bea7cf14ccf2e157fe3405cddfff3da`), so the
build is reproducible on F-Droid infra. The local reference checksum above
will NOT byte-match an F-Droid build because the Dart AOT snapshot embeds the
absolute checkout path (`/home/richard/RetroPod` vs F-Droid's build dir);
`libflutter.so` and `.text` are identical, only `.rodata`/`.eh_frame`/build-id
differ due to the embedded path.

## Steps to submit

1. Install fdroidserver locally to sanity-check the recipe first:
   `sudo apt install fdroidserver`, then
   `fdroid readmeta` and `fdroid build --test --server`.
2. Open a new-app request at https://gitlab.com/fdroid/fdroiddata/-/issues
   with the metadata and the reference checksum, or create a merge request
   in fdroiddata adding `metadata/com.rchrdariza.retropod.yml`.
3. Note for maintainers: two dependencies come from git
   (`adeeteya/Disable-Battery-Optimizations`, `adeeteya/on_audio_query` with
   `path: packages/on_audio_query`); `pubspec.lock` pins their commits.
   The APK has no INTERNET permission in the production flavor.

## Review risks to be aware of

- The app asks users to disable battery optimization (via the
  `disable_battery_optimization` git dependency); reviewers may ask why.
- The iPod icons from Flaticon are free-with-attribution, so F-Droid may
  flag the app with the `NonFreeAssets` anti-feature (a tag, not a blocker).
- The first Android build is ~89 MB (media_kit/on_audio_query + image
  thumbnails); consider `--split-per-abi` after inclusion to reduce size.