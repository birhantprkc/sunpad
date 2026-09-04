#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 2 || "$2" != /* ]]; then
  echo "usage: $0 <Apple-TV-device> /absolute/path/to/diagnostics" >&2
  exit 64
fi
DEVICE="$1"
DESTINATION="$2"
BUNDLE_IDENTIFIER="${SUNPAD_TVOS_BUNDLE_IDENTIFIER:-com.sunpad.SunPad.tv}"
mkdir -p "$DESTINATION"
xcrun devicectl device copy from --device "$DEVICE" \
  --source "Library/Caches/SunPad/Logs" --destination "$DESTINATION/Logs" \
  --domain-type appDataContainer --domain-identifier "$BUNDLE_IDENTIFIER"
find "$DESTINATION" -type f -name '*.log' -exec sed -i '' \
  -E 's#/private/var/mobile/Containers/Data/Application/[A-F0-9-]+#<app-container>#g' {} +
echo "Collected path-redacted SunPad tvOS diagnostics in $DESTINATION."
