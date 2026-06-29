-- WezTerm config matching Kun Chen's dotfiles-mac-nix style
-- (rose-pine-moon + Hack Nerd Font + frosted/transparent window).
-- Source: https://github.com/kunchenguid/dotfiles-mac-nix

local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- rose-pine-moon palette (so the tab/title bar matches the theme)
local rp = {
  base = "#232136",
  surface = "#2a273f",
  overlay = "#393552",
  muted = "#6e6a86",
  subtle = "#908caa",
  text = "#e0def4",
  rose = "#ea9a97",
  iris = "#c4a7e7",
}

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

config.color_scheme = "rose-pine-moon"
config.hide_tab_bar_if_only_one_tab = true
config.max_fps = 120
config.font = wezterm.font("Hack Nerd Font", { weight = "DemiBold" })
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
  font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
  -- title bar (with the integrated buttons) — match rose-pine instead of black
  active_titlebar_bg = rp.base,
  inactive_titlebar_bg = rp.base,
}
-- tab bar colors (layered on top of the rose-pine-moon color_scheme)
config.colors = {
  tab_bar = {
    background = rp.base,
    active_tab = {
      bg_color = rp.overlay,
      fg_color = rp.rose,
    },
    inactive_tab = {
      bg_color = rp.base,
      fg_color = rp.muted,
    },
    inactive_tab_hover = {
      bg_color = rp.surface,
      fg_color = rp.text,
    },
    new_tab = {
      bg_color = rp.base,
      fg_color = rp.muted,
    },
    new_tab_hover = {
      bg_color = rp.surface,
      fg_color = rp.text,
    },
  },
}
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}
-- push terminal content below the integrated window buttons, so the prompt's
-- first line (~) isn't covered by the three dots when the tab bar is hidden
config.window_padding = {
  left = 8,
  right = 8,
  top = 32,
  bottom = 8,
}

if is_windows then
  config.win32_system_backdrop = "Acrylic"
  config.window_background_opacity = 0.7
  config.window_frame.font_size = 10.0
end

if is_macos then
  config.window_background_opacity = 0.8
  config.macos_window_background_blur = 50
  config.font_size = 15.0
  config.window_frame.font_size = 13.0
end

return config
