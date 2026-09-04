#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
IPA="${1:?usage: scripts/audit-tvos-package.sh <SunPadTV.ipa>}"
[[ "$IPA" = /* ]] || IPA="$ROOT/$IPA"
fail() { echo "tvOS package audit failed: $*" >&2; exit 1; }

[[ -f "$IPA" ]] || fail "IPA not found"
unzip -tq "$IPA" >/dev/null || fail "ZIP integrity check failed"
ENTRIES="$(unzip -Z1 "$IPA")"
for required in \
  'Payload/SunPadTV.app/SunPadTV' \
  'Payload/SunPadTV.app/gGMSE01_recomp.dylib' \
  'Payload/SunPadTV.app/LICENSE' \
  'Payload/SunPadTV.app/THIRD_PARTY_NOTICES.md' \
  'Payload/SunPadTV.app/INSTALL_TVOS.md'; do
  grep -Fxq "$required" <<<"$ENTRIES" || fail "missing $required"
done
if grep -Eq '(^|/)\.\.(/|$)|^/|(^|/)__MACOSX(/|$)' <<<"$ENTRIES"; then
  fail "archive contains an unsafe path"
fi
if grep -Eiq '\.(iso|gcm|rvz|wia|wbfs|gcz|gci|sav|raw|log|mobileprovision|p12|p8|pem|key|cer)$|(^|/)_CodeSignature(/|$)' <<<"$ENTRIES"; then
  fail "archive contains private data or signing material"
fi

EXTRACT_ROOT="$(mktemp -d /tmp/sunpad-tvos-ipa-audit.XXXXXX)"
unzip -q "$IPA" -d "$EXTRACT_ROOT"
APP="$EXTRACT_ROOT/Payload/SunPadTV.app"
[[ "$(find "$EXTRACT_ROOT/Payload" -mindepth 1 -maxdepth 1 -type d -name '*.app' | wc -l | tr -d ' ')" = 1 ]] || fail "IPA must contain exactly one app"
"$ROOT/scripts/audit-tvos-app.sh" "$APP"
[[ ! -d "$APP/_CodeSignature" && ! -f "$APP/embedded.mobileprovision" ]] || fail "package is signed"
codesign --verify --strict "$APP" >/dev/null 2>&1 && fail "app signature remains"
codesign --verify --strict "$APP/gGMSE01_recomp.dylib" >/dev/null 2>&1 && fail "module signature remains"
echo "tvOS package audit passed: $IPA"
