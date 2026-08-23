#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

/bin/bash -n install.sh setup/*.sh tests/*.sh
/bin/zsh -n shell/zshrc.snippet
shellcheck --shell=bash install.sh setup/*.sh tests/*.sh

while IFS= read -r file; do
  luac -p "$file"
done < <(git ls-files --cached --others --exclude-standard '*.lua')

python3 - <<'PY'
import json
import pathlib
import tomllib

root = pathlib.Path("config")
for path in root.rglob("*.json"):
    json.loads(path.read_text())
for path in root.rglob("*.toml"):
    tomllib.loads(path.read_text())
PY

brew bundle list --file="$REPO_DIR/Brewfile" >/dev/null
STARSHIP_CONFIG="$REPO_DIR/config/starship.toml" starship print-config >/dev/null

socket="omarchy-ci-$$"
trap 'tmux -L "$socket" kill-server >/dev/null 2>&1 || true' EXIT
tmux -L "$socket" -f /dev/null new-session -d
tmux -L "$socket" source-file "$REPO_DIR/config/tmux/tmux.conf"
tmux -L "$socket" kill-server
trap - EXIT

if [ -n "${GITHUB_BASE_REF:-}" ]; then
  git diff --check "origin/$GITHUB_BASE_REF...HEAD"
elif [ -n "${GITHUB_ACTIONS:-}" ] && git rev-parse HEAD^ >/dev/null 2>&1; then
  git diff --check HEAD^ HEAD
else
  git diff --check
fi
/bin/bash tests/install_test.sh
lua tests/paperwm_recovery_test.lua

printf 'All tests passed.\n'
