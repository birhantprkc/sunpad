#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
runtime_patch="$repo_root/patches/ModernGekko/0001-sunpad-apple-runtime.patch"
runtime_source="$repo_root/ref/ModernGekko/src/runtime/dolphin_runtime.cpp"

check_runtime_config() {
  python3 - "$1" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
lines = path.read_text().splitlines()
if path.suffix == ".patch":
    lines = [line[1:] if line.startswith("+") and not line.startswith("+++") else line
             for line in lines]
text = "\n".join(lines)
expected = """#ifdef MODERNGEKKO_HAVE_IOS
  // StaticRecomp's empty block cache only observes invalidations. It cannot
  // use Dolphin's 64 GiB JIT entry-point map, which iOS refuses to reserve.
  Config::SetBase(Config::MAIN_LARGE_ENTRY_POINTS_MAP, false);
#endif"""
if expected not in text:
    raise SystemExit(f"missing iOS-only StaticRecomp entry-map override in {path}")
PY
}

check_runtime_config "$runtime_patch"
if [[ -f "$runtime_source" ]]; then
  check_runtime_config "$runtime_source"
fi

echo "iOS StaticRecomp configuration checks passed"
