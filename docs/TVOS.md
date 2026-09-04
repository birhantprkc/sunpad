# SunPad native tvOS preview

SunPad's first tvOS target is a deliberately narrow experimental hardware
bring-up path for Apple TV hardware running tvOS 17 or later.

The target shares SunPad's ModernGekko/Dolphin-derived Metal runtime, GMSE01
ahead-of-time module, audio host, controller mapping, input mixer, diagnostics,
and lifecycle handling. Its tvOS-specific surface is limited to a focus-driven
setup screen and Mac-side staging, backup, and diagnostic scripts.

## First-preview scope

- GMSE01 USA, disc 0, revision 0 only.
- Original 30 FPS, game-specific 16:9, 1x rendering, performance mode off.
- One Extended Gamepad, which may connect before or after launch. The Siri Remote is setup UI only.
- Direct GameController snapshots, binary controller haptics, and six-channel
  DPL2 output with a stereo fallback.
- User-provided extracted game data staged from a Mac.
- Offline play first; no touch controls or in-app file picker.

The tvOS app refuses to start until the extracted tree, disc header,
`sys/main.dol` hash, and bundled tvOS module are present. It starts without a
controller and adopts the first Extended Gamepad when one connects.

## Storage contract

tvOS treats filesystem-backed local data as purgeable. SunPad therefore stores
game data, configuration, memory-card state, and logs under
`Library/Caches/SunPad`. Testers must back up `Config` and `GC` before updating
or deleting the app and must be prepared to restage game data.

## Build

Prepare GMSE01 once, build the tvOS core and module, then build the app target:

```sh
./scripts/prepare-game.sh /absolute/path/to/GMSE01.iso
./scripts/tvos-build-core-device.sh
xcodebuild -project SunPad.xcodeproj -scheme SunPadTV -configuration Release \
  -destination 'generic/platform=tvOS' -derivedDataPath /tmp/SunPadTVDerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

Package and audit the unsigned preview only after the app build succeeds.

For the simulator gate, build and provision the same core and GMSE01 module for
the tvOS Simulator before building the `SunPadTV` target:

```sh
./scripts/tvos-build-core-simulator.sh
xcodebuild -project SunPad.xcodeproj -scheme SunPadTV -configuration Release \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation) (at 1080p)' \
  -derivedDataPath /tmp/SunPadTVSimulatorDerivedData build
```

The simulator follows the same controller-optional startup behavior as a device
build. Gameplay still requires an Extended Gamepad.
## Exact-artifact physical acceptance still required

- Missing data produces the setup screen rather than a crash.
- Valid staged GMSE01 data reaches the title screen and gameplay.
- Video, audible channel placement, FLUDD trigger pressure, Start, sticks,
  C-stick, and game-triggered haptics are correct.
- Controller disconnect/reconnect and sleep/wake release stale input.
- A save survives ordinary exit and relaunch.
- Backup and restore are rehearsed before meaningful progress is risked.
- A 30-minute gameplay run records frame pacing, audio, thermals, and failures.

Contributor hardware runs have demonstrated installation, boot, rendering,
six-channel audio initialization, controller/haptics setup, a live input-bridge
call, and clean-install staging. They do not replace the gates above on the
exact public artifact. Until those gates pass, describe the result as an
experimental tvOS build, not supported Apple TV functionality.
