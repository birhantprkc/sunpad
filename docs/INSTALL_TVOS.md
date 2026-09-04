# Install the experimental SunPad Apple TV build

SunPad 0.1.0 Preview 11 includes an unsigned ARM64 tvOS IPA for hardware
bring-up. It is experimental Apple TV functionality, not accepted support.

1. Download `SunPad-0.1.0-preview.11-tvos-unsigned.ipa` and verify the SHA-256
   from the Preview 11 release.
2. Re-sign the app and its nested `gGMSE01_recomp.dylib` with your own Apple
   development identity and bundle identifier, then install it on a paired
   Apple TV using Xcode or a compatible tvOS signing workflow.
3. Set `SUNPAD_TVOS_BUNDLE_IDENTIFIER` to the signed identifier before using
   any device script.
4. On your Mac, prepare your legally obtained GMSE01 USA revision-0 image with
   `scripts/prepare-game.sh`, then stage the extracted folder:

   ```sh
   ./scripts/stage-tvos-game-data.sh \
     "$PWD/ref/ModernGekko-Template/extracted/Super-Mario-Sunshine" \
     "Living Room"
   ```

5. Connect an Extended Gamepad and launch SunPad. The Siri Remote operates the
   setup screen but is not a gameplay controller.

The IPA contains the SunPad runtime and GMSE01 ahead-of-time recompiled module,
but no disc image, extracted assets, saves, signing identity, provisioning
profile, or device identifier. All filesystem-backed state is kept under
`Library/Caches/SunPad` and may be purged by tvOS. Back up configuration and
memory-card state before updating or deleting the app:

```sh
./scripts/backup-tvos-state.sh "Living Room" /absolute/path/to/new-backup
```

Collect diagnostics after a failure with `scripts/collect-tvos-diagnostics.sh`.
Review the output before sharing it. Never upload game data, saves, signing
material, device identifiers, or a complete app container.
