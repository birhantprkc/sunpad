#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
APP="${1:-/tmp/SunPadTVDerivedData/Build/Products/Release-appletvos/SunPadTV.app}"
OUTPUT="${2:-$ROOT/artifacts/SunPad-0.1.0-preview.11-tvos-unsigned.ipa}"
[[ "$APP" = /* ]] || APP="$ROOT/$APP"
[[ "$OUTPUT" = /* ]] || OUTPUT="$ROOT/$OUTPUT"
[[ -d "$APP" ]] || { echo "app not found: $APP" >&2; exit 1; }

PACKAGE_ROOT="$(mktemp -d /tmp/sunpad-tvos-package.XXXXXX)"
STAGED_APP="$PACKAGE_ROOT/Payload/SunPadTV.app"
mkdir -p "$(dirname "$STAGED_APP")" "$(dirname "$OUTPUT")"
ditto "$APP" "$STAGED_APP"
rm -rf "$STAGED_APP/_CodeSignature"
rm -f "$STAGED_APP/embedded.mobileprovision"
codesign --remove-signature "$STAGED_APP/gGMSE01_recomp.dylib" 2>/dev/null || true
codesign --remove-signature "$STAGED_APP" 2>/dev/null || true
cp "$ROOT/LICENSE" "$STAGED_APP/LICENSE"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$STAGED_APP/THIRD_PARTY_NOTICES.md"
cp "$ROOT/docs/INSTALL_TVOS.md" "$STAGED_APP/INSTALL_TVOS.md"

find "$PACKAGE_ROOT" -exec touch -h -t 200001010000 {} +
TEMPORARY_IPA="$PACKAGE_ROOT/SunPadTV.ipa"
(
  cd "$PACKAGE_ROOT"
  find Payload \( -type f -o -type l \) -print | LC_ALL=C sort | \
    zip -X -q -y "$TEMPORARY_IPA" -@
)
mv -f "$TEMPORARY_IPA" "$OUTPUT"
"$ROOT/scripts/audit-tvos-package.sh" "$OUTPUT"
echo "tvOS IPA: $OUTPUT"
shasum -a 256 "$OUTPUT"
