#!/usr/bin/env bash
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
"$ROOT/scripts/bootstrap-dependencies.sh"
echo "Pinned tvOS runtime: $ROOT/ref/ModernGekko-tvOS"
