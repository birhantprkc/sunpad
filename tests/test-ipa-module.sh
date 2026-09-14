#!/usr/bin/env bash
# Compile an unrelated ARM64 iOS library and ensure the real archive auditor rejects it.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT
APP="$TEMP/Payload/SunPad.app"
mkdir -p "$APP"
printf 'int unrelated_library(void) { return 0; }\n' | \
  xcrun --sdk iphoneos clang -target arm64-apple-ios16.0 -x c -dynamiclib - \
  -o "$APP/gGMSE01_recomp.dylib"
cp "$APP/gGMSE01_recomp.dylib" "$APP/SunPad"
cp "$ROOT/LICENSE" "$APP/LICENSE"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$APP/THIRD_PARTY_NOTICES.md"
(cd "$TEMP" && zip -qr fixture.ipa Payload)
if "$ROOT/scripts/audit-ios-package.sh" "$TEMP/fixture.ipa" > "$TEMP/result" 2>&1; then
  echo "Audit accepted unrelated module" >&2; exit 1
fi
grep -Fq 'module loader entry point is missing' "$TEMP/result"
echo "Unrelated iOS module correctly rejected"
