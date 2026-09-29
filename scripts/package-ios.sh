#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
# APP: a built SunPad.app, or the published SunPad IPA (the app without game code).
# MODULE: the player's gGMSE01_recomp.dylib, or "none" for the published app itself.
APP="${1:-/tmp/SunPadReleaseData/Build/Products/Release-iphoneos/SunPad.app}"
MODULE="${2:-/tmp/sunpad-module-ios-device/gGMSE01_recomp.dylib}"
OUTPUT="${3:-$ROOT/artifacts/SunPad-v$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$ROOT/version.json")-ios-personal-unsigned.ipa}"

[[ "$APP" = /* ]] || APP="$ROOT/$APP"
[[ "$MODULE" = none || "$MODULE" = /* ]] || MODULE="$ROOT/$MODULE"
[[ "$OUTPUT" = /* ]] || OUTPUT="$ROOT/$OUTPUT"
work_root="$(mktemp -d /tmp/sunpad-package.XXXXXX)"
trap 'rm -rf "$work_root"' EXIT
if [[ "$APP" = *.ipa ]]; then
  [[ -f "$APP" ]] || { echo "published app not found: $APP" >&2; exit 1; }
  ditto -x -k "$APP" "$work_root/published"
  APP="$work_root/published/Payload/SunPad.app"
  [[ ! -e "$APP/gGMSE01_recomp.dylib" ]] || { echo "the published app already contains a game module" >&2; exit 1; }
fi
[[ -d "$APP" ]] || { echo "app not found: $APP" >&2; exit 1; }
if [[ "$MODULE" = none ]]; then
  python3 "$ROOT/scripts/package-output.py" preflight "$OUTPUT" "$APP"
  export SUNPAD_APP_ONLY=1
else
  python3 "$ROOT/scripts/package-output.py" preflight "$OUTPUT" "$APP" "$MODULE"
  [[ -f "$MODULE" ]] || { echo "module not found: $MODULE" >&2; exit 1; }
fi

package_root="$work_root/package"
staged_app="$package_root/Payload/SunPad.app"
mkdir -p "$(dirname "$staged_app")" "$(dirname "$OUTPUT")"
ditto "$APP" "$staged_app"
[[ "$MODULE" = none ]] || ditto "$MODULE" "$staged_app/gGMSE01_recomp.dylib"

rm -rf "$staged_app/_CodeSignature"
rm -f "$staged_app/embedded.mobileprovision"
[[ "$MODULE" = none ]] || codesign --remove-signature "$staged_app/gGMSE01_recomp.dylib" 2>/dev/null || true
codesign --remove-signature "$staged_app" 2>/dev/null || true

# Keep only the device-relative module name; local host paths never belong in
# a public package.
if [[ -f "$staged_app/dev-config.plist" ]]; then
  /usr/libexec/PlistBuddy -c 'Delete :DevGameRoot' "$staged_app/dev-config.plist" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c 'Delete :DevModulePath' "$staged_app/dev-config.plist" 2>/dev/null || true
fi
cp "$ROOT/LICENSE" "$staged_app/LICENSE"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$staged_app/THIRD_PARTY_NOTICES.md"
cp "$ROOT/docs/INSTALL_IPA.md" "$staged_app/INSTALL_IPA.md"

rm -rf "$staged_app/SourceNotices"
"$ROOT/scripts/package-notices.sh" "$staged_app/SourceNotices"

find "$package_root" -exec touch -h -t 200001010000 {} +
temporary_ipa="$package_root/SunPad.ipa"
(
  cd "$package_root"
  find Payload \( -type f -o -type l \) -print | LC_ALL=C sort |
    zip -X -q -y "$temporary_ipa" -@
)
"$ROOT/scripts/audit-ios-package.sh" "$temporary_ipa"
python3 "$ROOT/scripts/package-output.py" publish "$OUTPUT" "$temporary_ipa"
echo "IPA: $OUTPUT"
shasum -a 256 "$OUTPUT"
echo "This unsigned IPA must be re-signed before installation."
