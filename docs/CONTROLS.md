# Touch and controller guide


SunPad uses a landscape layout designed separately for compact iPhones and
larger iPads:

- **Left:** movement stick, D-pad, and L within thumb reach.
- **Right:** camera stick, A/B/X/Y diamond, Z, R, and Start.
- **Menu:** the persistent **•••** button opens render resolution, aspect
  ratio, control, game-data, save, and diagnostic-log actions. Original 4:3
  is the default; 16:9 and Fill Screen are marked experimental and apply on
  the next launch.
- **Customize:** Move mode lets controls be dragged and saves normalized
  positions per device class; Reset restores the default layout.
- **Controller handoff:** a connected physical controller can hide the touch
  overlay automatically. Current Apple GameController enumeration is
  reconciled while active and after foreground resume; a valid controller keeps
  its player slot, a returning sole controller reclaims player 1, and stale
  player-1 input is released.

The four D-pad directions always move, resize, and reset as one layout group;
their gameplay hit regions remain four independent directions. R is a longer
horizontal pressure slider: touch its left edge for minimum spray pressure,
slide right for more pressure, and enter the final quarter for a haptic full
press. Keep the same finger down while sliding; moving past either edge clamps
to minimum or maximum pressure, and lifting releases R. The large-iPad default
layout is the normalized physical-iPad arrangement accepted on August 11,
2026. Phone layouts remain independently movable and are unchanged.

The **Controller Button Mapping…** menu is likewise narrow: GameCube A/B/X/Y/Z
can be assigned one-to-one across the four face buttons and left shoulder,
with conflicts swapped and a default reset. By default, the left shoulder is Z,
the right shoulder is a fixed 50% analog-R run-and-spray input, and the right
trigger retains the strong/full spray path. Sticks, D-pad, Start, the right
shoulder spray, and analog triggers stay fixed. Focused mapping and
controller-slot tests pass; physical Bluetooth, wired, and natural-sleep
reconnect acceptance remains open.

Touch and GameController input merge through the same thread-safe GameCube
state. Button presses are edge-latched, the strongest stick input wins, and
analog triggers preserve FLUDD pressure control.


See [macOS controls](MACOS.md#controls-and-data) for keyboard defaults and
[Apple TV setup](INSTALL_TVOS.md) for the Extended Gamepad workflow.
