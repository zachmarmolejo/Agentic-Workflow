#!/usr/bin/env bash
# Starship command substitutions are intentional test fixtures.
# shellcheck disable=SC2016
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/omarchy-install-tests.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  grep -Fq "$2" "$1" || fail "$1 does not contain: $2"
}

new_case() {
  CASE_DIR="$(mktemp -d "$TEST_ROOT/case.XXXXXX")"
  mkdir -p "$CASE_DIR/home" "$CASE_DIR/tmp" "$CASE_DIR/bin"
  COMMAND_LOG="$CASE_DIR/commands.log"
  : > "$COMMAND_LOG"

  cat > "$CASE_DIR/bin/uname" <<'EOF'
#!/bin/sh
if [ "${1:-}" = "-s" ]; then
  printf '%s\n' "${FAKE_UNAME_S:-Darwin}"
else
  printf '%s\n' "${FAKE_UNAME_M:-arm64}"
fi
EOF

  for command in brew bash defaults killall open; do
    cat > "$CASE_DIR/bin/$command" <<'EOF'
#!/bin/sh
printf '%s %s\n' "$(basename "$0")" "$*" >> "$FAKE_COMMAND_LOG"
exit 0
EOF
  done

  cat > "$CASE_DIR/bin/date" <<'EOF'
#!/bin/sh
printf '20260822-120000\n'
EOF

  chmod +x "$CASE_DIR/bin/"*
}

run_installer() {
  env -i \
    HOME="$CASE_DIR/home" \
    TMPDIR="$CASE_DIR/tmp" \
    PATH="$CASE_DIR/bin:/usr/bin:/bin" \
    OMARCHY_BREW_BIN="$CASE_DIR/bin/brew" \
    FAKE_COMMAND_LOG="$COMMAND_LOG" \
    FAKE_UNAME_S="${FAKE_UNAME_S:-Darwin}" \
    FAKE_UNAME_M="arm64" \
    /bin/bash "$REPO_DIR/install.sh"
}

assert_symlink() {
  [ -L "$1" ] || fail "$1 is not a symlink"
  [ "$(/usr/bin/stat -f '%Y' "$1")" = "$2" ] || fail "$1 has the wrong target"
}

new_case
FAKE_UNAME_S=Linux
if run_installer > "$CASE_DIR/stdout" 2> "$CASE_DIR/stderr"; then
  fail "non-macOS install unexpectedly succeeded"
fi
[ "$(< "$CASE_DIR/stderr")" = "Omarchy-Style-MacOS requires macOS." ] || fail "wrong non-macOS error"
[ -z "$(ls -A "$CASE_DIR/home")" ] || fail "non-macOS install changed HOME"
[ ! -s "$COMMAND_LOG" ] || fail "non-macOS install ran a side-effecting command"
unset FAKE_UNAME_S

new_case
run_installer > "$CASE_DIR/first.out"
assert_symlink "$CASE_DIR/home/.config/wezterm/wezterm.lua" "$REPO_DIR/config/wezterm/wezterm.lua"
assert_symlink "$CASE_DIR/home/.config/starship.toml" "$REPO_DIR/config/starship.toml"
assert_symlink "$CASE_DIR/home/.tmux.conf" "$REPO_DIR/config/tmux/tmux.conf"
assert_symlink "$CASE_DIR/home/.config/nvim" "$REPO_DIR/config/nvim"
assert_symlink "$CASE_DIR/home/.hammerspoon/init.lua" "$REPO_DIR/config/hammerspoon/init.lua"
assert_symlink "$CASE_DIR/home/.hammerspoon/paperwm_recovery.lua" "$REPO_DIR/config/hammerspoon/paperwm_recovery.lua"
assert_symlink "$CASE_DIR/home/.local/bin/omarchy-window-management" "$REPO_DIR/bin/omarchy-window-management"
assert_contains "$COMMAND_LOG" "brew bundle --file=$REPO_DIR/Brewfile"
assert_contains "$COMMAND_LOG" "open -a Hammerspoon"
if grep -Fq "wallpaper" "$COMMAND_LOG"; then
  fail "installer invoked wallpaper setup"
fi
[ ! -e "$CASE_DIR/home/Pictures/Wallpapers" ] || fail "installer created a wallpaper directory"
[ "$(grep -c '# >>> Omarchy-Style-MacOS >>>' "$CASE_DIR/home/.zshrc")" -eq 1 ] || fail "wrong managed block count"
[ "$(grep -Ec '^[[:space:]]*eval[[:space:]]+.*starship init zsh' "$CASE_DIR/home/.zshrc")" -eq 1 ] || fail "wrong Starship init count"
assert_contains "$CASE_DIR/home/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
first_hash="$(shasum "$CASE_DIR/home/.zshrc")"
first_backups="$(find "$CASE_DIR/home" -name '*.bak.*' | wc -l | tr -d ' ')"
run_installer > "$CASE_DIR/second.out"
[ "$first_hash" = "$(shasum "$CASE_DIR/home/.zshrc")" ] || fail "second install changed .zshrc"
[ "$first_backups" = "$(find "$CASE_DIR/home" -name '*.bak.*' | wc -l | tr -d ' ')" ] || fail "second install added backups"
assert_contains "$CASE_DIR/second.out" "already linked"

new_case
mkdir -p "$CASE_DIR/home/.config/wezterm"
ln -s "/tmp/obsolete-wezterm.lua" "$CASE_DIR/home/.config/wezterm/wezterm.lua"
run_installer >/dev/null
assert_symlink "$CASE_DIR/home/.config/wezterm/wezterm.lua" "$REPO_DIR/config/wezterm/wezterm.lua"
assert_symlink "$CASE_DIR/home/.config/wezterm/wezterm.lua.bak.20260822-120000" "/tmp/obsolete-wezterm.lua"

new_case
cat > "$CASE_DIR/home/.zshrc" <<'EOF'
export BEFORE=1
# >>> Agentic-Workflow >>>
eval "$(starship init zsh)"
alias cat='batcat'
# <<< Agentic-Workflow <<<
export AFTER=1
EOF
run_installer >/dev/null
if grep -q 'Agentic-Workflow\|batcat' "$CASE_DIR/home/.zshrc"; then
  fail "legacy shell block was not removed"
fi
[ "$(grep -c '# >>> Omarchy-Style-MacOS >>>' "$CASE_DIR/home/.zshrc")" -eq 1 ] || fail "legacy block was not migrated"
assert_contains "$CASE_DIR/home/.zshrc" "export BEFORE=1"
assert_contains "$CASE_DIR/home/.zshrc" "export AFTER=1"

for fixture in commented indented-comment guarded conditional; do
  new_case
  case "$fixture" in
    commented) printf '# eval "$(starship init zsh)"\n' > "$CASE_DIR/home/.zshrc" ;;
    indented-comment) printf '  # command -v starship >/dev/null && eval "$(starship init zsh)"\n' > "$CASE_DIR/home/.zshrc" ;;
    guarded) printf 'command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"\n' > "$CASE_DIR/home/.zshrc" ;;
    conditional)
      cat > "$CASE_DIR/home/.zshrc" <<'EOF'
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
EOF
      ;;
  esac
  run_installer >/dev/null
  active_count="$(grep -Ec '^[[:space:]]*([^#[:space:]][^#]*&&[[:space:]]*)?eval[[:space:]]+.*starship init zsh' "$CASE_DIR/home/.zshrc")"
  [ "$active_count" -eq 1 ] || fail "$fixture fixture has $active_count active Starship initializers"
done

printf 'Installer tests passed.\n'
