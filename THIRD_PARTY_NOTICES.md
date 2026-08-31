# Third-party notices

SunPad's own integration source is licensed under the GNU General Public
License, version 3 or later. The project builds against separately cloned,
pinned upstream repositories; their source and license files remain in those
checkouts and are not vendored into this repository.

| Component | Pin | License / notice |
|---|---|---|
| ModernGekko | `0514d9f03f8602809f66fc92fdca87d30e752997` | GPL-3.0-or-later |
| ModernGekko vendored Dolphin/RecompCore | `13e492094902644b0d113c586300d358640f9e19` | Dolphin aggregate is GPLv3-compatible; per-file SPDX terms apply |
| DolRecomp | `fa0cf619e8d7eb8cba7eaf55267a12caaebb46aa` | GPL-3.0-or-later |
| ModernGekko-Template | `1ee85bb5e09c38f493a09f5fa6e9dc8228b23e42` | Build template; its dependencies retain their upstream licenses |

See [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md) for URLs, purposes, and the
complete dependency inventory. A distributed binary that incorporates the
GPL-covered runtime must be accompanied by the corresponding source and the
applicable license notices as required by those licenses.

Super Mario Sunshine, Nintendo, and GameCube names, game imagery, and
screenshots are owned by their respective rights holders. They are not
licensed under the GPL and are used here only to identify compatibility and
document runtime behavior. No retail image, extracted asset, generated
game-derived module, or save is included.

The SunPad icon is a project-specific AI-generated image. Its provenance is
recorded beside the asset in
[`apple/ios/Assets.xcassets/AppIcon.appiconset/PROVENANCE.md`](apple/ios/Assets.xcassets/AppIcon.appiconset/PROVENANCE.md).
