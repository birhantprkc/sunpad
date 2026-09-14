#!/usr/bin/env bash
# Clean-source runtime + app link check. No game input, signing or installation.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
LANE="${1:?usage: check-apple-build.sh <ios|tvos>}"
case "$LANE" in
  ios) SDK=iphonesimulator; MG="$ROOT/ref/ModernGekko"; MINIMUM=16.0; TARGET=SunPad;
       TOOLCHAIN="$ROOT/scripts/ios-simulator-toolchain.cmake"; PROVISION=ios-provision.sh ;;
  tvos) SDK=appletvsimulator; MG="$ROOT/ref/ModernGekko-tvOS"; MINIMUM=17.0; TARGET=SunPadTV;
        TOOLCHAIN="$ROOT/scripts/tvos-device-toolchain.cmake"; PROVISION=tvos-provision-device.sh ;;
  *) exit 2 ;;
esac
python3 "$ROOT/scripts/dependency-lock.py"
BUILD="$MG/build-$LANE-$SDK-public"
cmake -S "$MG" -B "$BUILD" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" -DCMAKE_OSX_SYSROOT="$SDK" \
  -DCMAKE_SYSTEM_PROCESSOR=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET="$MINIMUM" \
  -DCMAKE_BUILD_TYPE=Release -DENABLE_QT=OFF -DENABLE_TESTS=OFF \
  -DUSE_DISCORD_PRESENCE=OFF -DUSE_MGBA=OFF -DUSE_RETRO_ACHIEVEMENTS=OFF \
  -DENABLE_AUTOUPDATE=OFF -DENABLE_ANALYTICS=OFF -DUSE_UPNP=OFF \
  -DMODERNGEKKO_ENABLE_DOLPHIN_TESTS=OFF -DENABLE_CUBEB=OFF -DENABLE_VULKAN=OFF \
  -DUSE_SYSTEM_FMT=OFF -DUSE_SYSTEM_LZ4=OFF -DUSE_SYSTEM_ZSTD=OFF \
  -DUSE_SYSTEM_XXHASH=OFF -DHAVE_PIPE2=0
cmake --build "$BUILD" --target libmoderngekko.a -j4
# Reuse the production archive inventory, without provisioning private game inputs.
python3 - "$ROOT" "$LANE" "$SDK" "$BUILD" "$PROVISION" <<'PY'
import pathlib,re,subprocess,sys
root=pathlib.Path(sys.argv[1]);lane,sdk,build,provision=sys.argv[2:]
source=(root/'scripts'/provision).read_text().split('LIBS=(',1)[1].split('\n)',1)[0]
libs=[x.replace('$IOS_BUILD',build).replace('$TVOS_BUILD',build) for x in re.findall(r'"([^"]+\.a)"',source)]
assert libs and all(pathlib.Path(p).is_file() for p in libs)
out=root/'apple'/lane/'Provisioned'/sdk/'libs';out.mkdir(parents=True,exist_ok=True)
subprocess.run(['libtool','-static','-o',str(out/'libSunPadCore.a'),*libs],check=True)
PY
if [[ "$LANE" = tvos ]]; then
  # Resource fixture only. No StaticRecomp loader export, so release audits reject it.
  printf 'void sunpad_ci_non_game_fixture(void) {}\n' | \
    xcrun --sdk "$SDK" clang -x c -dynamiclib -arch arm64 \
      -target arm64-apple-tvos17.0-simulator - \
      -o "$ROOT/apple/tvos/Provisioned/$SDK/gGMSE01_recomp.dylib"
else
  printf '<?xml version="1.0"?><plist version="1.0"><dict/></plist>\n' > "$ROOT/apple/ios/Provisioned/dev-config.plist"
fi
xcodebuild -project "$ROOT/SunPad.xcodeproj" -scheme "$TARGET" -configuration Release \
  -sdk "$SDK" -destination "generic/platform=$( [[ "$LANE" = ios ]] && echo 'iOS Simulator' || echo 'tvOS Simulator' )" \
  -derivedDataPath "$ROOT/build/ci-$LANE" CODE_SIGNING_ALLOWED=NO build
python3 "$ROOT/scripts/dependency-lock.py"
echo "$LANE runtime and host build passed. This is not a playable or releasable package."
