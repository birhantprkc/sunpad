#!/usr/bin/env bash
set -euo pipefail

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
host="$repo_root/apple/ios/SunPadCoreHost.mm"
runtime_patch="$repo_root/patches/ModernGekko/0001-sunpad-apple-runtime.patch"

grep -Fq 'BOOL suppressHeatwave = mode != SunPadAspectRatioOriginal;' "$host"
grep -Fq '_runtime->SetGMSE01HeatwaveSuppressed(true);' "$host"
grep -Fq '_runtime->SetGMSE01HeatwaveSuppressed(false);' "$host"
grep -Fq 'GMSE01_HEATWAVE_ENTRY = 0x8019F83Cu' "$runtime_patch"
grep -Fq 'PPC_BLR = {0x4E, 0x80, 0x00, 0x20}' "$runtime_patch"
grep -Fq 'std::thread startup_patch_thread([this]' "$runtime_patch"
grep -Fq 'Core::AddOnStateChangedCallback([this](Core::State state)' "$runtime_patch"
grep -Fq 'Core::State::Starting)' "$runtime_patch"
grep -Fq 'Core::State::Running)' "$runtime_patch"
grep -Fq 'debug.SetPatch(guard, GMSE01_HEATWAVE_ENTRY' "$runtime_patch"
grep -Fq 'debug.UnsetPatch(guard, GMSE01_HEATWAVE_ENTRY);' "$runtime_patch"

echo "Widescreen heatwave guard checks passed"
