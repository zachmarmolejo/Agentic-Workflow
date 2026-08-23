#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Wallpaper setup requires macOS." >&2
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$REPO_DIR/assets/wallpaper.png"
DEST_DIR="$HOME/Pictures/Wallpapers/Omarchy-Style-MacOS"
DEST="$DEST_DIR/wallpaper.png"

if [ ! -f "$SOURCE" ]; then
  echo "Wallpaper asset not found: $SOURCE" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
if [ -L "$DEST" ] || { [ -e "$DEST" ] && ! cmp -s "$SOURCE" "$DEST"; }; then
  BACKUP="$DEST.bak.$(date +%Y%m%d-%H%M%S)"
  SUFFIX=1
  while [ -e "$BACKUP" ] || [ -L "$BACKUP" ]; do
    BACKUP="$DEST.bak.$(date +%Y%m%d-%H%M%S).$SUFFIX"
    SUFFIX=$((SUFFIX + 1))
  done
  mv "$DEST" "$BACKUP"
  printf 'Existing wallpaper backed up: %s\n' "$BACKUP"
fi
if ! cmp -s "$SOURCE" "$DEST"; then
  cp "$SOURCE" "$DEST"
fi

osascript - "$DEST" <<'APPLESCRIPT'
on run argv
  set wallpaperFile to POSIX file (item 1 of argv)
  tell application "System Events"
    repeat with desktopItem in desktops
      set picture of desktopItem to wallpaperFile
    end repeat
  end tell
end run
APPLESCRIPT

printf 'Wallpaper installed: %s\n' "$DEST"
