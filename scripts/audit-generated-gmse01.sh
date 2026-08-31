#!/usr/bin/env bash
# Rejects GMSE01 C output from DolRecomp revisions that emitted Gekko scalar
# floating-point operations as host arithmetic. That form loses paired-register
# and Gekko pipeline semantics and can corrupt Sunshine's model transforms.
set -euo pipefail

GEN=${1:?usage: scripts/audit-generated-gmse01.sh <generated-dir>}
CHUNKS="$GEN/chunks"

fail() {
  echo "generated GMSE01 audit failed: $*" >&2
  exit 1
}

search_chunks() {
  local pattern=$1 file
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$CHUNKS" -g '*.c'
    return
  fi
  while IFS= read -r file; do
    if grep -Eq "$pattern" "$file"; then
      return 0
    fi
  done < <(find "$CHUNKS" -type f -name '*.c' -print)
  return 1
}

[[ -f "$GEN/generated.c" && -f "$GEN/generated.h" && -d "$CHUNKS" ]] ||
  fail "incomplete DolRecomp output: $GEN"

if search_chunks 'ctx->fpr\[[^]]+\] = \(f64\)\(f32\)\(ctx->fpr'; then
  fail "obsolete direct scalar floating-point arithmetic is present; regenerate with the pinned DolRecomp"
fi
if search_chunks 'ppc_fp_available\('; then
  fail "obsolete out-of-line FP availability gates are present; regenerate with the pinned DolRecomp"
fi

for required in \
  'ppc_fp_available_inline\(' \
  'ppc_psq_load_inline\(' \
  'ppc_psq_store_inline\(' \
  'ppc_fdivs\(' \
  'ppc_ps_madd_op\('
do
  search_chunks "$required" ||
    fail "expected corrected helper emission is missing: $required"
done

echo "generated GMSE01 audit passed: $GEN"
