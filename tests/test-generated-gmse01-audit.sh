#!/usr/bin/env bash
set -euo pipefail

root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
fixture="$(mktemp -d /tmp/sunpad-generated-audit.XXXXXX)"
trap 'rm -rf "$fixture"' EXIT

mkdir -p "$fixture/chunks"
touch "$fixture/generated.c" "$fixture/generated.h"
cat > "$fixture/chunks/corrected.c" <<'EOF'
ppc_fp_available_inline(ctx);
ppc_psq_load_inline(ctx);
ppc_psq_store_inline(ctx);
ppc_fdivs(ctx);
ppc_ps_madd_op(ctx);
EOF

"$root/scripts/audit-generated-gmse01.sh" "$fixture" >/dev/null

cat >> "$fixture/chunks/corrected.c" <<'EOF'
ctx->fpr[2] = (f64)(f32)(ctx->fpr[2] / ctx->fpr[0]);
EOF

if "$root/scripts/audit-generated-gmse01.sh" "$fixture" >/dev/null 2>&1; then
  echo "stale scalar floating-point output passed the generated-code audit" >&2
  exit 1
fi

echo "Generated GMSE01 floating-point audit regression test passed"
