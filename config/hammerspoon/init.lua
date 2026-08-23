require("hs.ipc")

hs.autoLaunch(true)
hs.window.animationDuration = 0

if not hs.accessibilityState(true) then
  hs.accessibilityStateCallback = function()
    if hs.accessibilityState() then
      hs.reload()
    end
  end
  return
end

local function ensureDesktopSpaces(minimum)
  local spaces, err = hs.spaces.spacesForScreen("Main")
  if not spaces then
    hs.printf("Could not inspect desktop Spaces: %s", err)
    return
  end

  local userSpaces = 0
  for _, space in ipairs(spaces) do
    if hs.spaces.spaceType(space) == "user" then
      userSpaces = userSpaces + 1
    end
  end

  for _ = userSpaces + 1, minimum do
    local ok, addErr = hs.spaces.addSpaceToScreen("Main", false)
    if not ok then
      hs.spaces.closeMissionControl()
      hs.printf("Could not create desktop Space: %s", addErr)
      return
    end
  end

  if userSpaces < minimum then
    hs.spaces.closeMissionControl()
  end
end

ensureDesktopSpaces(4)

PaperWM = hs.loadSpoon("PaperWM")

PaperWM.window_gap = 12
PaperWM.screen_margin = 8
PaperWM.default_width = 0.62
PaperWM.window_ratios = { 0.38, 0.5, 0.62, 0.75 }
PaperWM.infinite_loop_window = true
PaperWM.center_mouse = true

-- Native horizontal Space gestures are disabled by the installer.
PaperWM.swipe_fingers = 3
PaperWM.swipe_gain = 1.0
PaperWM.scroll_window = { "cmd", "alt" }
PaperWM.scroll_gain = 10

-- Cmd+Alt mirrors Omarchy's Super+mouse window movement.
PaperWM.drag_window = { "cmd", "alt" }
PaperWM.lift_window = { "cmd", "alt", "shift" }

PaperWM:bindHotkeys({
  focus_left = { { "cmd", "alt" }, "left" },
  focus_right = { { "cmd", "alt" }, "right" },
  focus_up = { { "cmd", "alt" }, "up" },
  focus_down = { { "cmd", "alt" }, "down" },

  swap_left = { { "cmd", "alt", "shift" }, "left" },
  swap_right = { { "cmd", "alt", "shift" }, "right" },
  swap_up = { { "cmd", "alt", "shift" }, "up" },
  swap_down = { { "cmd", "alt", "shift" }, "down" },

  decrease_width = { { "cmd", "alt" }, "-" },
  increase_width = { { "cmd", "alt" }, "=" },
  decrease_height = { { "cmd", "alt", "shift" }, "-" },
  increase_height = { { "cmd", "alt", "shift" }, "=" },
  center_window = { { "cmd", "alt" }, "c" },
  full_width = { { "cmd", "alt" }, "f" },

  slurp_in = { { "cmd", "alt" }, "i" },
  barf_out = { { "cmd", "alt" }, "o" },
  split_screen = { { "cmd", "alt" }, "s" },
  toggle_floating = { { "cmd", "alt" }, "t" },
  focus_floating = { { "cmd", "alt", "shift" }, "f" },

  switch_space_l = { { "cmd", "alt" }, "," },
  switch_space_r = { { "cmd", "alt" }, "." },
  switch_recent_space = { { "cmd", "alt", "ctrl" }, "tab" },
  switch_space_1 = { { "cmd", "alt" }, "1" },
  switch_space_2 = { { "cmd", "alt" }, "2" },
  switch_space_3 = { { "cmd", "alt" }, "3" },
  switch_space_4 = { { "cmd", "alt" }, "4" },
  move_window_1 = { { "cmd", "alt", "shift" }, "1" },
  move_window_2 = { { "cmd", "alt", "shift" }, "2" },
  move_window_3 = { { "cmd", "alt", "shift" }, "3" },
  move_window_4 = { { "cmd", "alt", "shift" }, "4" },

  refresh_windows = { { "cmd", "alt", "shift" }, "r" },
  refresh_windows_forcedly = { { "cmd", "alt", "ctrl", "shift" }, "r" },
})

local paperwmRecovery = require("paperwm_recovery").new(hs, PaperWM)
local cycleNextWindow = paperwmRecovery.cycleNextWindow
local cyclePreviousWindow = paperwmRecovery.cyclePreviousWindow

hs.hotkey.bind({ "cmd", "alt" }, "j", cycleNextWindow)
hs.hotkey.bind({ "cmd", "alt", "shift" }, "j", cyclePreviousWindow)

local function bindSwapAlias(key, direction)
  hs.hotkey.bind({ "cmd", "alt", "ctrl" }, key, function()
    PaperWM.windows.swapWindows(direction)
  end)
end

bindSwapAlias("left", PaperWM.windows.Direction.LEFT)
bindSwapAlias("right", PaperWM.windows.Direction.RIGHT)
bindSwapAlias("up", PaperWM.windows.Direction.UP)
bindSwapAlias("down", PaperWM.windows.Direction.DOWN)

local function openWezTerm()
  local appPath = hs.application.pathForBundleID("com.github.wez.wezterm")
  if not appPath then
    hs.alert.show("WezTerm is not installed")
    return
  end

  local executable = appPath .. "/Contents/MacOS/wezterm"
  local task = hs.task.new(executable, function(exitCode, _, stderr)
    if exitCode ~= 0 then
      hs.alert.show("Could not open WezTerm: " .. stderr)
    end
  end, { "start", "--cwd", os.getenv("HOME") })
  task:start()
end

local function tileNewBrowserWindow(app, existingWindowIDs, attemptsRemaining)
  for _, window in ipairs(app:allWindows()) do
    if not existingWindowIDs[window:id()] then
      local index = PaperWM.state.windowIndex(window)
      local space = index and index.space or hs.spaces.windowSpaces(window)[1]
      if space then
        if not index then
          space = PaperWM.windows.addWindow(window)
        end
        if space then
          PaperWM:tileSpace(space, window)
          window:focus()
          return
        end
      end
    end
  end

  if attemptsRemaining > 0 then
    hs.timer.doAfter(0.02, function()
      tileNewBrowserWindow(app, existingWindowIDs, attemptsRemaining - 1)
    end)
  end
end

local function openBrowser()
  local bundleID = hs.urlevent.getDefaultHandler("http")
  if not bundleID then
    hs.alert.show("Could not open the default browser")
    return
  end

  local app = hs.application.get(bundleID)
  if app then
    local existingWindowIDs = {}
    for _, window in ipairs(app:allWindows()) do
      existingWindowIDs[window:id()] = true
    end

    app:activate()
    if not app:selectMenuItem({ "File", "New Window" }) then
      hs.alert.show("Could not open a new browser window")
    else
      tileNewBrowserWindow(app, existingWindowIDs, 25)
    end
  elseif not hs.application.launchOrFocusByBundleID(bundleID) then
    hs.alert.show("Could not open the default browser")
  end
end

hs.hotkey.bind({ "cmd", "alt" }, "return", openWezTerm)
hs.hotkey.bind({ "cmd", "alt", "shift" }, "return", openBrowser)

local paperActions = PaperWM.actions.actions()
local customKeybindingActions = {
  open_wezterm = openWezTerm,
  open_browser = openBrowser,
  focus_next = cycleNextWindow,
  focus_prev = cyclePreviousWindow,
}

local function bindSilentMove(index)
  local actionName = "move_window_silent_" .. index
  local action = function()
    local previousSetting = PaperWM.move_window_keep_space
    PaperWM.move_window_keep_space = true
    local ok, err = xpcall(function()
      PaperWM.space.moveWindowToSpace(index)
    end, debug.traceback)
    PaperWM.move_window_keep_space = previousSetting
    if not ok then
      PaperWM.logger.e(err)
    end
  end

  customKeybindingActions[actionName] = action
  hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, tostring(index), action)
end

for index = 1, 4 do
  bindSilentMove(index)
end

local keybindingChoices = {
  { text = "Command+Option+Space", subText = "Search this keybinding reference" },
  { text = "Command+Option+Return", subText = "Open a new WezTerm shell window", action = "open_wezterm" },
  { text = "Command+Option+Shift+Return", subText = "Open a new default-browser window", action = "open_browser" },
  { text = "Command+Option+Left", subText = "Focus and pan left", action = "focus_left" },
  { text = "Command+Option+Right", subText = "Focus and pan right", action = "focus_right" },
  { text = "Command+Option+Up", subText = "Focus the window above", action = "focus_up" },
  { text = "Command+Option+Down", subText = "Focus the window below", action = "focus_down" },
  { text = "Command+Option+Shift+Left", subText = "Swap the focused window left", action = "swap_left" },
  { text = "Command+Option+Shift+Right", subText = "Swap the focused window right", action = "swap_right" },
  { text = "Command+Option+Shift+Up", subText = "Swap the focused window up", action = "swap_up" },
  { text = "Command+Option+Shift+Down", subText = "Swap the focused window down", action = "swap_down" },
  { text = "Command+Option+Control+Arrow", subText = "Alternate directional swap binding" },
  { text = "Command+Option+J", subText = "Cycle to the next window", action = "focus_next" },
  { text = "Command+Option+Shift+J", subText = "Cycle to the previous window", action = "focus_prev" },
  { text = "Command+Option+-", subText = "Decrease window width", action = "decrease_width" },
  { text = "Command+Option+=", subText = "Increase window width", action = "increase_width" },
  { text = "Command+Option+Shift+-", subText = "Decrease window height", action = "decrease_height" },
  { text = "Command+Option+Shift+=", subText = "Increase window height", action = "increase_height" },
  { text = "Command+Option+I", subText = "Stack into the column on the left", action = "slurp_in" },
  { text = "Command+Option+O", subText = "Remove from the current column", action = "barf_out" },
  { text = "Command+Option+S", subText = "Split the current column", action = "split_screen" },
  { text = "Command+Option+T", subText = "Toggle floating", action = "toggle_floating" },
  { text = "Command+Option+Shift+F", subText = "Focus a floating window", action = "focus_floating" },
  { text = "Command+Option+F", subText = "Toggle full width" },
  { text = "Command+Option+C", subText = "Center the focused window", action = "center_window" },
  { text = "Command+Option+1", subText = "Switch to Space 1", action = "switch_space_1" },
  { text = "Command+Option+2", subText = "Switch to Space 2", action = "switch_space_2" },
  { text = "Command+Option+3", subText = "Switch to Space 3", action = "switch_space_3" },
  { text = "Command+Option+4", subText = "Switch to Space 4", action = "switch_space_4" },
  { text = "Command+Option+Shift+1", subText = "Move the focused window to Space 1", action = "move_window_1" },
  { text = "Command+Option+Shift+2", subText = "Move the focused window to Space 2", action = "move_window_2" },
  { text = "Command+Option+Shift+3", subText = "Move the focused window to Space 3", action = "move_window_3" },
  { text = "Command+Option+Shift+4", subText = "Move the focused window to Space 4", action = "move_window_4" },
  { text = "Command+Option+Control+Shift+1", subText = "Move the focused window to Space 1 without following", action = "move_window_silent_1" },
  { text = "Command+Option+Control+Shift+2", subText = "Move the focused window to Space 2 without following", action = "move_window_silent_2" },
  { text = "Command+Option+Control+Shift+3", subText = "Move the focused window to Space 3 without following", action = "move_window_silent_3" },
  { text = "Command+Option+Control+Shift+4", subText = "Move the focused window to Space 4 without following", action = "move_window_silent_4" },
  { text = "Command+Option+,", subText = "Switch to the previous Space", action = "switch_space_l" },
  { text = "Command+Option+.", subText = "Switch to the next Space", action = "switch_space_r" },
  { text = "Command+Option+Control+Tab", subText = "Return to the former Space", action = "switch_recent_space" },
  { text = "Command+Option+Shift+R", subText = "Refresh PaperWM's window state", action = "refresh_windows" },
  { text = "Command+Option+Control+Shift+R", subText = "Force-refresh and retile all windows", action = "refresh_windows_forcedly" },
  { text = "Command+Option+scroll", subText = "Pan the window strip" },
  { text = "Command+Option+drag", subText = "Pan the window strip" },
  { text = "Command+Option+Shift+drag", subText = "Lift and reposition a window" },
  { text = "Three-finger horizontal swipe", subText = "Pan the window strip" },
  { text = "Pointer hover", subText = "Focus the window under the pointer" },
}

local keybindingChooser = hs.chooser.new(function(choice)
  if not choice or not choice.action then
    return
  end

  local action = customKeybindingActions[choice.action] or paperActions[choice.action]
  if action then
    hs.timer.doAfter(0.1, action)
  end
end)
keybindingChooser:choices(keybindingChoices)
keybindingChooser:placeholderText("Search PaperWM keybindings; Return runs the selected action")
keybindingChooser:searchSubText(true)
keybindingChooser:rows(14)

local keybindingReturnWindowID = nil

local function finderSearchWindows()
  local windows = {}
  for _, window in ipairs(hs.window.orderedWindows()) do
    local app = window:application()
    if app and app:bundleID() == "com.apple.finder" and window:title():match("^Searching") then
      windows[window:id()] = window
    end
  end
  return windows
end

local function showKeybindings(delay)
  local focusedWindow = hs.window.focusedWindow()
  keybindingReturnWindowID = focusedWindow and focusedWindow:id() or nil
  local existingSearchWindows = finderSearchWindows()

  local dismissFinderSearch = function()
    for id, window in pairs(finderSearchWindows()) do
      if not existingSearchWindows[id] then
        window:close()
      end
    end
  end

  if delay and delay > 0 then
    hs.timer.doAfter(delay, function()
      dismissFinderSearch()
      -- Let PaperWM finish reacting to the transient Finder window closing.
      hs.timer.doAfter(0.3, function()
        keybindingChooser:show()
      end)
    end)
  else
    keybindingChooser:show()
  end
end

keybindingChooser:hideCallback(function()
  local windowID = keybindingReturnWindowID
  keybindingReturnWindowID = nil
  if windowID then
    hs.timer.doAfter(0.05, function()
      local window = hs.window.get(windowID)
      if window then
        window:focus()
      end
    end)
  end
end)

hs.hotkey.bind({ "cmd", "alt" }, "space", function()
  showKeybindings(0.2)
end)
hs.hotkey.bind({ "cmd", "alt" }, "k", function()
  showKeybindings()
end)

local function isManagedWindow(window)
  if not window then
    return false
  end

  for _, managedWindow in ipairs(PaperWM.window_filter:getWindows()) do
    if managedWindow:id() == window:id() then
      return true
    end
  end

  return false
end

local activeBorder = hs.canvas.new({ x = 0, y = 0, w = 1, h = 1 })
activeBorder[1] = {
  type = "rectangle",
  action = "stroke",
  frame = { x = "0%", y = "0%", w = "100%", h = "100%" },
  padding = 2,
  roundedRectRadii = { xRadius = 8, yRadius = 8 },
  strokeColor = { hex = "33CCFF", alpha = 0.95 },
  strokeWidth = 3,
}
activeBorder:behavior({ "canJoinAllSpaces", "fullScreenAuxiliary", "stationary", "ignoresCycle" })
activeBorder:level(hs.canvas.windowLevels.overlay)
activeBorder:clickActivating(false)
activeBorder:wantsLayer(true)

local function updateActiveBorder()
  local window = hs.window.focusedWindow()
  if not isManagedWindow(window) then
    activeBorder:hide()
    return
  end

  activeBorder:frame(window:frame())
  activeBorder:show()
end

local borderWindowFilter = hs.window.filter.new()
borderWindowFilter:subscribe({
  hs.window.filter.windowFocused,
  hs.window.filter.windowMoved,
  hs.window.filter.windowUnfullscreened,
}, updateActiveBorder)
borderWindowFilter:subscribe({
  hs.window.filter.windowDestroyed,
  hs.window.filter.windowUnfocused,
  hs.window.filter.windowFullscreened,
  hs.window.filter.windowNotVisible,
}, function()
  hs.timer.doAfter(0.05, updateActiveBorder)
end)

local hoverCheckPending = false
local hoverWatcher = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, function()
  if hoverCheckPending or keybindingChooser:isVisible() then
    return false
  end

  hoverCheckPending = true
  hs.timer.doAfter(0.08, function()
    hoverCheckPending = false
    if keybindingChooser:isVisible() then
      return
    end

    local buttons = hs.eventtap.checkMouseButtons()
    if buttons.left or buttons.right or buttons.middle then
      return
    end

    local point = hs.mouse.absolutePosition()
    for _, window in ipairs(hs.window.orderedWindows()) do
      local frame = window:frame()
      local containsPoint = point.x >= frame.x and point.x <= frame.x2
        and point.y >= frame.y and point.y <= frame.y2
      if containsPoint and isManagedWindow(window) then
        local focusedWindow = hs.window.focusedWindow()
        if not focusedWindow or focusedWindow:id() ~= window:id() then
          window:focus()
        end
        break
      end
    end
  end)

  return false
end)

PaperWM.keybindingChooser = keybindingChooser
PaperWM.activeBorder = activeBorder
PaperWM.borderWindowFilter = borderWindowFilter
PaperWM.hoverWatcher = hoverWatcher
PaperWM.openBrowser = openBrowser
PaperWM.repairWindowState = paperwmRecovery.repairWindowState
PaperWM.cycleNextWindow = cycleNextWindow
PaperWM.cyclePreviousWindow = cyclePreviousWindow

PaperWM:start()
PaperWM.hoverWatcher:start()
updateActiveBorder()
