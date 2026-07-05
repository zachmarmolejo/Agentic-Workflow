#!/usr/bin/env bash
#
# Bootstrap and verify the LazyVim install after config/nvim is linked.
# Called by install.sh - safe to run directly after editing the nvim config.
#
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$1"; }

info "Bootstrapping LazyVim plugins..."
if ! command -v nvim >/dev/null 2>&1; then
  echo "nvim not found - install Neovim before bootstrapping LazyVim" >&2
  exit 1
fi

# Use the committed lazy-lock.json instead of updating plugin pins during install.
nvim --headless "+Lazy! restore" +qa

info "Verifying LazyVim dashboard..."
nvim --headless \
  '+lua
    local ok_lazy = pcall(require, "lazy")
    assert(ok_lazy, "lazy.nvim did not load")

    local ok_snacks = pcall(require, "snacks")
    assert(ok_snacks, "snacks.nvim did not load")
    assert(Snacks and Snacks.dashboard, "Snacks dashboard did not load")

    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    local dashboard = vim.api.nvim_get_hl(0, { name = "SnacksDashboardNormal" })
    assert(normal.bg == nil, "Normal background should stay transparent")
    assert(dashboard.bg ~= nil, "Dashboard background should be opaque in WezTerm")

    Snacks.dashboard.open()
    vim.cmd("redraw")

    local found = false
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].filetype == "snacks_dashboard" then
        found = true
        break
      end
    end
    assert(found, "LazyVim dashboard buffer did not open")
  ' +qa

ok "LazyVim ready"
