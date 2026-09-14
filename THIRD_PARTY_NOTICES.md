# Third-party notices

SunPad's own integration source is licensed under the GNU General Public
License, version 3 or later. The project builds against separately cloned,
pinned maintained forks of upstream repositories; their source and license files remain in those
checkouts and are not vendored into this repository.

The exact Apple/tvOS commits, original upstream bases and repository URLs are
recorded in [the dependency lock](config/dependencies.lock.json). ModernGekko and
DolRecomp retain their GPL notices. RecompCore retains Dolphin's per-file SPDX
terms and third-party licenses. The template retains its original notices.
[CREDITS.md](CREDITS.md) identifies the projects and contributor roles.

See [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md) for URLs, purposes, and the
complete dependency inventory. A distributed binary that incorporates the
GPL-covered runtime must be accompanied by the corresponding source and the
applicable license notices as required by those licenses.

Super Mario Sunshine, Nintendo, and GameCube names, game imagery, and
screenshots are owned by their respective rights holders. They are not
licensed under the GPL and are used here only to identify compatibility and
document runtime behavior. No retail image, extracted asset or save is included. The source repository
excludes generated game modules. Published preview IPAs include the required
GMSE01 AOT executable module. That distinction does not license Nintendo material
under SunPad's GPL license.

The SunPad icon is a project-specific AI-generated image. Its provenance is
recorded beside the asset in
[`apple/ios/Assets.xcassets/AppIcon.appiconset/PROVENANCE.md`](apple/ios/Assets.xcassets/AppIcon.appiconset/PROVENANCE.md).
