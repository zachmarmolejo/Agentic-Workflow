#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/omarchy-wallpaper-tests.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT
mkdir -p "$TEST_DIR/home" "$TEST_DIR/bin"

cat > "$TEST_DIR/bin/uname" <<'EOF'
#!/bin/sh
printf '%s\n' "${FAKE_UNAME_S:-Darwin}"
EOF
cat > "$TEST_DIR/bin/osascript" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$FAKE_OSASCRIPT_LOG"
cat > "$FAKE_OSASCRIPT_BODY"
EOF
cat > "$TEST_DIR/bin/date" <<'EOF'
#!/bin/sh
printf '20260822-120000\n'
EOF
chmod +x "$TEST_DIR/bin/uname" "$TEST_DIR/bin/osascript" "$TEST_DIR/bin/date"

export HOME="$TEST_DIR/home"
export PATH="$TEST_DIR/bin:/usr/bin:/bin"
export FAKE_OSASCRIPT_LOG="$TEST_DIR/osascript.log"
export FAKE_OSASCRIPT_BODY="$TEST_DIR/osascript-body.log"

/bin/bash "$REPO_DIR/setup/wallpaper.sh" >/dev/null
installed="$HOME/Pictures/Wallpapers/Omarchy-Style-MacOS/wallpaper.png"
cmp -s "$REPO_DIR/assets/wallpaper.png" "$installed"
[ "$(< "$FAKE_OSASCRIPT_LOG")" = "- $installed" ]
grep -Fq 'repeat with desktopItem in desktops' "$FAKE_OSASCRIPT_BODY"
grep -Fq 'set picture of desktopItem to wallpaperFile' "$FAKE_OSASCRIPT_BODY"
first_hash="$(shasum "$installed")"
/bin/bash "$REPO_DIR/setup/wallpaper.sh" >/dev/null
[ "$first_hash" = "$(shasum "$installed")" ]

printf 'existing user wallpaper\n' > "$installed"
/bin/bash "$REPO_DIR/setup/wallpaper.sh" >/dev/null
[ "$(< "$installed.bak.20260822-120000")" = "existing user wallpaper" ]
[ "$first_hash" = "$(shasum "$installed")" ]

if FAKE_UNAME_S=Linux /bin/bash "$REPO_DIR/setup/wallpaper.sh" >/dev/null 2> "$TEST_DIR/error"; then
  printf 'FAIL: non-macOS wallpaper setup unexpectedly succeeded\n' >&2
  exit 1
fi
[ "$(< "$TEST_DIR/error")" = "Wallpaper setup requires macOS." ]

printf 'Wallpaper tests passed.\n'
