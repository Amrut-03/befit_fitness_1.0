#!/usr/bin/env bash
# Release builds for Play (AAB) and sideloading (one APK per ABI).
#
# --obfuscate --split-debug-info strips Dart symbols out of libapp.so; they
# are kept in build/symbols/<version> so Crashlytics can still symbolicate
# Dart stack traces once uploaded (see the end of this script).
#
# Usage: tool/build_release.sh [extra flutter build args, e.g. --dart-define=GEMMA_MODEL_URL=...]
set -euo pipefail
cd "$(dirname "$0")/.."

version=$(grep '^version:' pubspec.yaml | awk '{print $2}')
symbols="build/symbols/$version"
flags=(--release --obfuscate --split-debug-info="$symbols" "$@")

flutter build appbundle "${flags[@]}"
flutter build apk --split-per-abi "${flags[@]}"

echo
echo "AAB:  build/app/outputs/bundle/release/app-release.aab"
echo "APKs: build/app/outputs/flutter-apk/app-*-release.apk"
echo "Dart symbols: $symbols"
echo
echo "Upload Dart symbols to Crashlytics:"
echo "  firebase crashlytics:symbols:upload --app=1:475383477382:android:0e3c563b237c312fc44d07 $symbols"
