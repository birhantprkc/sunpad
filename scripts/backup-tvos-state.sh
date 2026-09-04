#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 2 || "$2" != /* ]]; then
  echo "usage: $0 <Apple-TV-device> /absolute/path/to/backup" >&2
  exit 64
fi
DEVICE="$1"
DESTINATION="$2"
BUNDLE_IDENTIFIER="${SUNPAD_TVOS_BUNDLE_IDENTIFIER:-com.sunpad.SunPad.tv}"
mkdir -p "$DESTINATION"
for item in Config GC; do
  xcrun devicectl device copy from --device "$DEVICE" \
    --source "Library/Caches/SunPad/$item" --destination "$DESTINATION/$item" \
    --domain-type appDataContainer --domain-identifier "$BUNDLE_IDENTIFIER"
done
echo "Backed up SunPad configuration and memory-card state to $DESTINATION."
