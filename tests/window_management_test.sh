#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/omarchy-window-management-tests.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

COMMAND_LOG="$TEST_ROOT/commands.log"
HS_STUB="$TEST_ROOT/hs"

cat > "$HS_STUB" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$COMMAND_LOG"
EOF
chmod +x "$HS_STUB"

run_command() {
  env -i \
    HOME="$TEST_ROOT/home" \
    PATH="/usr/bin:/bin" \
    COMMAND_LOG="$COMMAND_LOG" \
    OMARCHY_HS_BIN="$HS_STUB" \
    /bin/bash "$REPO_DIR/bin/omarchy-window-management" "$@"
}

mkdir -p "$TEST_ROOT/home"
: > "$COMMAND_LOG"

[ "$(run_command status)" = "Omarchy window management is enabled." ]
[ "$(run_command disable)" = "Omarchy window management disabled; windows are now freely positionable." ]
[ -e "$TEST_ROOT/home/.local/state/omarchy-style-macos/window-management-disabled" ]
grep -Fq 'PaperWM:stop()' "$COMMAND_LOG"
grep -Fq 'hs.reload()' "$COMMAND_LOG"
[ "$(run_command status)" = "Omarchy window management is disabled." ]

: > "$COMMAND_LOG"
[ "$(run_command toggle)" = "Omarchy window management enabled." ]
[ ! -e "$TEST_ROOT/home/.local/state/omarchy-style-macos/window-management-disabled" ]
grep -Fq 'hs.reload()' "$COMMAND_LOG"

[ "$(run_command toggle)" = "Omarchy window management disabled; windows are now freely positionable." ]
[ "$(run_command enable)" = "Omarchy window management enabled." ]

if run_command invalid >/dev/null 2>&1; then
  printf 'FAIL: invalid command unexpectedly succeeded.\n' >&2
  exit 1
fi

printf 'Window management command tests passed.\n'
