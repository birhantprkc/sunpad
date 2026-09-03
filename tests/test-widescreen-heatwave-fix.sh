#!/usr/bin/env bash
set -euo pipefail

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
host="$repo_root/apple/ios/SunPadCoreHost.mm"
overlay="$repo_root/apple/ios/SunPadGameOverlay.mm"
runtime_patch="$repo_root/patches/ModernGekko/0001-sunpad-apple-runtime.patch"

grep -Fq 'BOOL suppressHeatwave = mode != SunPadAspectRatioOriginal;' "$host"
grep -Fq 'config.enable_gmse01_widescreen = savedAspect != SunPadAspectRatioOriginal;' "$host"
grep -Fq 'Config::SetCurrent(Config::GFX_WIDESCREEN_HACK, false);' "$host"
if grep -Fq 'Config::SetCurrent(Config::GFX_WIDESCREEN_HACK, true);' "$host"; then
  echo "The generic Dolphin widescreen hack must remain disabled for Sunshine" >&2
  exit 1
fi
grep -Fq 'runtime aspect pending=%ld source=menu nextLaunch=1' "$host"
grep -Fq '16:9 (Experimental, Restart Required)' "$overlay"
grep -Fq 'The game-specific Sunshine widescreen correction is selected.' "$overlay"
grep -Fq '_runtime->SetGMSE01HeatwaveSuppressed(true);' "$host"
grep -Fq '_runtime->SetGMSE01HeatwaveSuppressed(false);' "$host"
grep -Fq 'bool enable_gmse01_widescreen = false;' "$runtime_patch"
grep -Fq 'std::string("Widescreen")' "$runtime_patch"
grep -Fq 'impl->config.enable_gmse01_widescreen' "$runtime_patch"
grep -Fq 'Gecko::UpdateSyncedCodes(no_codes);' "$runtime_patch"
grep -Fq 'Config::SetBase(Config::MAIN_ENABLE_CHEATS, false);' "$runtime_patch"
grep -Fq 'GMSE01_HEATWAVE_ENTRY = 0x8019F83Cu' "$runtime_patch"
grep -Fq 'PPC_BLR = {0x4E, 0x80, 0x00, 0x20}' "$runtime_patch"
grep -Fq 'GMSE01_HEATWAVE_ORIGINAL = {0x7C, 0x08, 0x02, 0xA6}' "$runtime_patch"
grep -Fq 'gmse01_heatwave_patch_applied{false}' "$runtime_patch"
grep -Fq 'std::thread startup_patch_thread([this]' "$runtime_patch"
grep -Fq 'Core::AddOnStateChangedCallback([this](Core::State state)' "$runtime_patch"
grep -Fq 'Core::State::Starting)' "$runtime_patch"
grep -Fq 'Core::State::Running)' "$runtime_patch"
grep -Fq 'debug.SetPatch(guard, GMSE01_HEATWAVE_ENTRY' "$runtime_patch"
grep -Fq 'std::vector<u8>(GMSE01_HEATWAVE_ORIGINAL.begin(),' "$runtime_patch"
if grep -Fq 'debug.UnsetPatch(guard, GMSE01_HEATWAVE_ENTRY);' "$runtime_patch"; then
  echo "One-shot UnsetPatch does not restore the original GMSE01 instruction" >&2
  exit 1
fi

if [[ -f "$repo_root/ref/ModernGekko/vendor/dolphin/Data/Sys/GameSettings/GMSE01.ini" ]]; then
  grep -Fq -- '$Widescreen [gamemasterplc]' \
    "$repo_root/ref/ModernGekko/vendor/dolphin/Data/Sys/GameSettings/GMSE01.ini"
fi

echo "GMSE01 widescreen and heatwave guard checks passed"
