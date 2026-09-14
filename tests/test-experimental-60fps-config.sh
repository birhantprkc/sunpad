#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_binary="$(mktemp "${TMPDIR:-/tmp}/sunpad-60fps-config.XXXXXX")"
trap 'rm -f "$test_binary"' EXIT

runtime_header="$repo_root/ref/ModernGekko/include/moderngekko/runtime.hpp"
runtime_source="$repo_root/ref/ModernGekko/src/runtime/dolphin_runtime.cpp"


[[ -f "$runtime_header" ]] || { echo "Run bootstrap-dependencies.sh --sources-only first" >&2; exit 1; }
  clang++ \
    -std=c++23 \
    -I "$repo_root/ref/ModernGekko/include" \
    "$repo_root/tests/SunPadExperimental60FPSConfigTests.cpp" \
    -o "$test_binary"
  "$test_binary"

grep -Fq -- '-sunpadExperimental60FPS' \
  "$repo_root/apple/ios/SunPadCoreHost.mm"
grep -Fq -- 'SunPadExperimental60FPS' \
  "$repo_root/apple/shared/SunPadSettings.mm"
grep -Fq -- '60 FPS Patch (Unstable, Restart Required)' \
  "$repo_root/apple/ios/SunPadGameOverlay.mm"
grep -Fq -- 'It is not a performance boost and is known to be unsuitable for normal play.' \
  "$repo_root/apple/ios/SunPadGameOverlay.mm"
grep -Fq -- 'Use Supported 30 FPS Mode (Restart Required)' \
  "$repo_root/apple/ios/SunPadGameOverlay.mm"
grep -Fq -- 'menuPreference60FPS' \
  "$repo_root/apple/ios/SunPadCoreHost.mm"
grep -Fq -- '!stableBaseline && (launchArgument60FPS || menuPreference60FPS)' \
  "$repo_root/apple/ios/SunPadCoreHost.mm"
grep -Fq -- 'impl->metadata.disc_id != "GMSE01"' \
  "$runtime_source"
grep -Fq -- 'Config::SetBase(Config::MAIN_ENABLE_CHEATS, true);' \
  "$runtime_source"
grep -Fq -- 'Config::SetBase(Config::SESSION_CODE_SYNC_OVERRIDE, true);' \
  "$runtime_source"

if [[ -f "$repo_root/ref/ModernGekko/vendor/dolphin/Data/Sys/GameSettings/GMSE01.ini" ]]; then
  grep -Fq -- '$60FPS [gamemasterplc]' \
    "$repo_root/ref/ModernGekko/vendor/dolphin/Data/Sys/GameSettings/GMSE01.ini"
fi

echo "Experimental 60 FPS configuration checks passed"
