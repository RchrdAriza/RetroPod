#!/usr/bin/env bash
#
# Verifies the Android release build is reproducible by building the APK twice
# and comparing SHA-256 checksums.
#
# Requirements:
#   - Flutter SDK on PATH
#   - Android SDK configured (flutter doctor passes)
#
# Usage: scripts/verify_reproducible_build.sh
set -euo pipefail

cd "$(dirname "$0")/.."

APK=build/app/outputs/flutter-apk/app-production-release.apk
TMP1=$(mktemp)
TMP2=$(mktemp)
trap 'rm -f "$TMP1" "$TMP2"' EXIT

echo "First build..."
flutter build apk --release --no-pub --suppress-analytics \
  --flavor=production --target=lib/main.dart
cp "$APK" "$TMP1"
H1=$(sha256sum "$TMP1" | awk '{print $1}')

echo "Second build..."
flutter build apk --release --no-pub --suppress-analytics \
  --flavor=production --target=lib/main.dart
cp "$APK" "$TMP2"
H2=$(sha256sum "$TMP2" | awk '{print $1}')

echo "sha256 #1: $H1"
echo "sha256 #2: $H2"

if [ "$H1" = "$H2" ]; then
  echo "Build reproducible."
else
  echo "Build NOT reproducible."
  exit 1
fi