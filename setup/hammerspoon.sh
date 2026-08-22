#!/usr/bin/env bash
set -euo pipefail

PAPERWM_REPO="https://github.com/mogenson/PaperWM.spoon"
PAPERWM_COMMIT="1510c8ca419c8ebdd1966e7ab4668341c5eb80d0"
SPOONS_DIR="$HOME/.hammerspoon/Spoons"
PAPERWM_DIR="$SPOONS_DIR/PaperWM.spoon"

mkdir -p "$SPOONS_DIR"

if [ -d "$PAPERWM_DIR/.git" ]; then
  ORIGIN="$(git -C "$PAPERWM_DIR" remote get-url origin)"
  if [ "$ORIGIN" != "$PAPERWM_REPO" ]; then
    printf 'PaperWM checkout has an unexpected origin: %s\n' "$ORIGIN" >&2
    exit 1
  fi
  if [ -n "$(git -C "$PAPERWM_DIR" status --porcelain)" ]; then
    printf 'PaperWM checkout has local changes: %s\n' "$PAPERWM_DIR" >&2
    exit 1
  fi
  git -C "$PAPERWM_DIR" fetch origin release
elif [ -e "$PAPERWM_DIR" ]; then
  printf 'PaperWM destination exists but is not a git checkout: %s\n' "$PAPERWM_DIR" >&2
  exit 1
else
  git clone --branch release --single-branch "$PAPERWM_REPO" "$PAPERWM_DIR"
fi

git -C "$PAPERWM_DIR" checkout --detach "$PAPERWM_COMMIT"

if [ "$(git -C "$PAPERWM_DIR" rev-parse HEAD)" != "$PAPERWM_COMMIT" ]; then
  printf 'PaperWM did not resolve to pinned commit %s\n' "$PAPERWM_COMMIT" >&2
  exit 1
fi
