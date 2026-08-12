#!/usr/bin/env bash
set -euo pipefail

root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
overlay="$root/apple/ios/SunPadGameOverlay.mm"

grep -Fq 'UIUserInterfaceIdiomPhone' "$overlay"
grep -Fq '0.1234722222, 0.7803490991' "$overlay"
grep -Fq '0.9233055556, 0.8130067568' "$overlay"
grep -Fq '0.0812777778, 0.4677364865' "$overlay"
grep -Fq '1.158457040786743' "$overlay"
grep -Fq 'savedScales[identifier] != nil' "$overlay"
if grep -Fq 'CGRect aDefault = phone ?' "$overlay"; then
  echo "iPhone A must retain the original fallback because it was absent from the sparse capture" >&2
  exit 1
fi
grep -Fq 'CGRectGetMaxX(safe) - margin - large' "$overlay"
grep -Fq '0.1310395315, 0.7905894519' "$overlay"
grep -Fq '0.2686676428, 0.7947259566' "$overlay"

echo "iPhone touch-layout default checks passed"
