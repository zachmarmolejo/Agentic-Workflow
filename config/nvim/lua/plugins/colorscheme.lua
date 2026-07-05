-- Match the terminal: rose-pine (moon), with transparency so WezTerm's
-- opacity + background blur shows through normal editing buffers.
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "moon",
      styles = {
        transparency = true,
      },
      highlight_groups = {
        -- Keep LazyVim/Snacks dashboard readable inside translucent WezTerm.
        SnacksDashboardNormal = { bg = "base" },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine-moon",
    },
  },
}
