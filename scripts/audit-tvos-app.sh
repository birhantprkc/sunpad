#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 || "$1" != /* || "$1" != *.app ]]; then
  echo "usage: $0 /absolute/path/to/SunPadTV.app [bundle-id]" >&2
  exit 64
fi
APP="$1"
BUNDLE_IDENTIFIER="${2:-com.sunpad.SunPad.tv}"
EXECUTABLE="$APP/SunPadTV"
MODULE="$APP/gGMSE01_recomp.dylib"

fail() { echo "tvOS app audit failed: $*" >&2; exit 1; }

[[ -x "$EXECUTABLE" ]] || fail "app executable is missing"
[[ -f "$MODULE" ]] || fail "tvOS GMSE01 module is missing"
[[ -f "$APP/Info.plist" && -f "$APP/PrivacyInfo.xcprivacy" ]] || fail "metadata is missing"
[[ -f "$APP/Assets.car" ]] || fail "compiled tvOS assets are missing"
[[ -d "$APP/Sys" ]] || fail "Dolphin Sys data is missing"
plutil -lint "$APP/Info.plist" "$APP/PrivacyInfo.xcprivacy" >/dev/null
[[ "$(lipo -archs "$EXECUTABLE")" = arm64 ]] || fail "app is not arm64-only"
[[ "$(lipo -archs "$MODULE")" = arm64 ]] || fail "module is not arm64-only"
for binary in "$EXECUTABLE" "$MODULE"; do
  vtool -show-build "$binary" | grep -Eq 'platform +TVOS$' || fail "non-tvOS Mach-O: $binary"
  vtool -show-build "$binary" | grep -Eq 'minos +17\.0$' || fail "unexpected minimum tvOS: $binary"
  while IFS= read -r dependency; do
    case "$dependency" in
      /System/Library/*|/usr/lib/*) ;;
      "@rpath/$(basename "$MODULE")") [[ "$binary" = "$MODULE" ]] ||
        fail "unexpected module install name on $binary" ;;
      *)
      fail "non-system dynamic dependency in $binary: $dependency" ;;
    esac
  done < <(otool -L "$binary" | tail -n +2 | awk '{print $1}')
done
[[ "$(plutil -extract CFBundleIdentifier raw "$APP/Info.plist")" = "$BUNDLE_IDENTIFIER" ]] || fail "unexpected bundle identifier"
[[ "$(plutil -extract CFBundleExecutable raw "$APP/Info.plist")" = SunPadTV ]] || fail "unexpected executable name"
[[ "$(plutil -extract CFBundleShortVersionString raw "$APP/Info.plist")" = 0.1.0 ]] || fail "unexpected version"
[[ "$(plutil -extract CFBundleVersion raw "$APP/Info.plist")" = 12 ]] || fail "unexpected build number"
[[ "$(plutil -extract MinimumOSVersion raw "$APP/Info.plist")" = 17.0 ]] || fail "unexpected plist minimum"
[[ "$(plutil -extract GCSupportsControllerUserInteraction raw "$APP/Info.plist")" = true ]] || fail "controller support metadata is missing"
[[ "$(plutil -extract GCSupportedGameControllers.0.ProfileName raw "$APP/Info.plist")" = ExtendedGamepad ]] || fail "ExtendedGamepad metadata is missing"
[[ "$(plutil -extract CFBundleIcons.CFBundlePrimaryIcon raw "$APP/Info.plist")" = "App Icon - Small" ]] || fail "primary tvOS icon metadata is missing"
[[ "$(plutil -extract TVTopShelfImage.TVTopShelfPrimaryImage raw "$APP/Info.plist")" = "Top Shelf Image" ]] || fail "Top Shelf metadata is missing"

nm -gjU "$MODULE" | grep -Fxq _staticrecomp_get_module || fail "module entry point is missing"
for binary in "$EXECUTABLE" "$MODULE"; do
  if xcrun llvm-objdump -d "$binary" | grep -Eiq '\bldap(r|ur)[[:alpha:]]*\b'; then
    fail "binary contains an A12-only RCpc load instruction: $binary"
  fi
done

for forbidden in '*.iso' '*.gcm' '*.rvz' '*.wia' '*.wbfs' '*.gcz' '*.gci' \
  '*.raw' '*.sav' '*.log' '*.mobileprovision' '*.p12' '*.pem' '*.key' \
  'GameData' 'BundledGameData' 'SaveData'; do
  [[ -z "$(find "$APP" -name "$forbidden" -print -quit)" ]] || fail "forbidden private data: $forbidden"
done
for file in "$EXECUTABLE" "$MODULE"; do
  if LC_ALL=C strings -a "$file" | grep -E '/Users/|/Volumes/|github_pat_|gh[pousr]_|AKIA[0-9A-Z]{16}' >/dev/null; then
    fail "personal path or likely credential in $file"
  fi
done

ASSET_INFO="$(xcrun assetutil --info "$APP/Assets.car")"
grep -Fq '"Name" : "App Icon - Small"' <<<"$ASSET_INFO" || fail "small tvOS icon is missing"
for rendition in background-large.png circuit-large.png mark-large.png; do
  grep -Fq "\"RenditionName\" : \"$rendition\"" <<<"$ASSET_INFO" || fail "large tvOS icon layer is missing: $rendition"
done
grep -Fq '"Name" : "Top Shelf Image"' <<<"$ASSET_INFO" || fail "Top Shelf image is missing"
echo "tvOS app audit passed: $APP"
shasum -a 256 "$EXECUTABLE" "$MODULE"
