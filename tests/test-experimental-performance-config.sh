#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_binary="$(mktemp "${TMPDIR:-/tmp}/sunpad-performance-config.XXXXXX")"
trap 'rm -f "$test_binary"' EXIT

runtime_header="$repo_root/ref/ModernGekko/include/moderngekko/runtime.hpp"
runtime_source="$repo_root/ref/ModernGekko/src/runtime/dolphin_runtime.cpp"
runtime_patch="$repo_root/patches/ModernGekko/0001-sunpad-apple-runtime.patch"

if [[ -f "$runtime_header" ]]; then
  clang++ \
    -std=c++23 \
    -I "$repo_root/ref/ModernGekko/include" \
    "$repo_root/tests/SunPadExperimentalPerformanceConfigTests.cpp" \
    -o "$test_binary"
  "$test_binary"
else
  grep -Fq -- 'std::optional<float> emulated_cpu_clock_scale;' "$runtime_patch"
  runtime_source="$runtime_patch"
fi

grep -Fq -- '-sunpadExperimentalPerformanceMode' \
  "$repo_root/apple/ios/SunPadCoreHost.mm"
grep -Fq -- 'SunPadExperimentalPerformanceMode' \
  "$repo_root/apple/shared/SunPadSettings.mm"
grep -Fq -- 'Experimental Performance Mode (Restart Required)' \
  "$repo_root/apple/ios/SunPadGameOverlay.mm"
if grep -Fq -- 'Config::SetBase(Config::MAIN_CPU_THREAD, true);' "$runtime_source"; then
  echo "Rejected dual-core performance path is still present" >&2
  exit 1
fi
grep -Fq -- 'Config::SetBase(Config::MAIN_OVERCLOCK_ENABLE, true);' \
  "$runtime_source"
grep -Fq -- 'Config::SetBase(Config::MAIN_OVERCLOCK, *impl->config.emulated_cpu_clock_scale);' \
  "$runtime_source"
grep -Fq -- 'QOS_CLASS_USER_INITIATED' \
  "$repo_root/apple/ios/SunPadCoreHost.mm"
grep -Fq -- 'experimental-single-core-90 cpuVideoSplit=0 emulatedCPUClock=0.90' \
  "$repo_root/apple/ios/SunPadCoreHost.mm"

echo "Experimental performance configuration checks passed"
