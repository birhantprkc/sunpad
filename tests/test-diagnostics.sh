#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
mkdir -p "$TEMP_DIR/home"

clang++ -x objective-c++ -std=gnu++2b -fobjc-arc \
  -framework Foundation \
  -I"$ROOT/apple/shared" \
  "$ROOT/apple/shared/SunPadDiagnostics.mm" \
  "$ROOT/tests/SunPadDiagnosticsTests.mm" \
  -o "$TEMP_DIR/SunPadDiagnosticsTests"

CFFIXED_USER_HOME="$TEMP_DIR/home" "$TEMP_DIR/SunPadDiagnosticsTests"

overlay="$ROOT/apple/ios/SunPadGameOverlay.mm"
issue_form="$ROOT/.github/ISSUE_TEMPLATE/bug_report.yml"
for field in report-id revision platform performance-profile summary context frequency; do
  rg -q "queryItemWithName:@\"$field\"" "$overlay"
  rg -q "id: $field" "$issue_form"
done
rg -q 'actionWithTitle:@"Report a Problem…"' "$overlay"
rg -q 'id: diagnostic-report' "$issue_form"
rg -q 'id: visual-evidence' "$issue_form"
rg -q 'accept: "\.log,\.txt"' "$issue_form"
echo "SunPad diagnostic UI and GitHub issue-form contract passed"
