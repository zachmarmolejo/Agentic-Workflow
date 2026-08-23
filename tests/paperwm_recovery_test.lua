local root = assert(io.popen("pwd")):read("*l")
package.path = root .. "/config/hammerspoon/?.lua;" .. package.path

local recoveryModule = require("paperwm_recovery")
local testsRun = 0

local function assertEqual(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)), 2)
  end
end

local function test(name, fn)
  local ok, err = xpcall(fn, debug.traceback)
  if not ok then
    io.stderr:write("FAIL: ", name, "\n", err, "\n")
    os.exit(1)
  end
  testsRun = testsRun + 1
end

local function newWindow(id, space, x)
  local window = {
    _id = id,
    space = space,
    _frame = { x = x, y = 10, w = 700, h = 900 },
    focusCount = 0,
  }
  function window:id() return self._id end
  function window:isFullScreen() return false end
  function window:frame()
    return { x = self._frame.x, y = self._frame.y, w = self._frame.w, h = self._frame.h }
  end
  return window
end

local function newFixture(layout)
  local windows = {}
  for _, columns in pairs(layout) do
    for _, rows in ipairs(columns) do
      for _, window in ipairs(rows) do windows[window:id()] = window end
    end
  end

  local state = { layout = layout, indexes = {}, xPositionsBySpace = {} }
  local function rebuildIndexes()
    state.indexes = {}
    for space, columns in pairs(state.layout) do
      state.xPositionsBySpace[space] = state.xPositionsBySpace[space] or {}
      for col, rows in ipairs(columns) do
        for row, window in ipairs(rows) do
          state.indexes[window:id()] = { space = space, col = col, row = row }
          if state.xPositionsBySpace[space][window:id()] == nil then
            state.xPositionsBySpace[space][window:id()] = window:frame().x
          end
        end
      end
    end
  end
  rebuildIndexes()

  local function rowsProxy(space, col)
    local rows = state.layout[space] and state.layout[space][col]
    if not rows then return nil end
    return setmetatable({}, {
      __index = function(_, row) return rows[row] end,
      __newindex = function(_, row, value)
        rows[row] = value
        if #rows == 0 then table.remove(state.layout[space], col) end
        rebuildIndexes()
      end,
      __len = function() return #rows end,
    })
  end

  local function columnsProxy(space)
    local columns = state.layout[space]
    return setmetatable({}, {
      __index = function(_, col) return columns and columns[col] end,
      __newindex = function(_, col, value)
        state.layout[space] = state.layout[space] or {}
        state.layout[space][col] = value
        rebuildIndexes()
      end,
      __len = function() return columns and #columns or 0 end,
    })
  end

  local hs = { focused = nil, timers = 0 }
  hs.window = { animationDuration = 0 }
  function hs.window.focusedWindow() return hs.focused end
  hs.timer = {}
  function hs.timer.doAfter(_, callback) hs.timers = hs.timers + 1; callback() end
  hs.spaces = {}
  function hs.spaces.windowSpaces(window) return { window.space } end

  for _, window in pairs(windows) do
    function window:focus()
      self.focusCount = self.focusCount + 1
      if not self.delayFocus or self.focusCount > 1 then hs.focused = self end
    end
  end

  local PaperWM = {
    default_width = 0.62,
    startCount = 0,
    stopCount = 0,
    moveCount = 0,
    errors = {},
    nativeFocusResult = nil,
  }
  PaperWM.window_filter = { getWindows = function() local result = {}; for _, window in pairs(windows) do table.insert(result, window) end; return result end }
  PaperWM.floating = { isFloating = function() return false end }
  PaperWM.events = { stop = function() PaperWM.stopCount = PaperWM.stopCount + 1 end }
  PaperWM.logger = { e = function(err) table.insert(PaperWM.errors, err) end }
  PaperWM.state = {}
  function PaperWM.state.windowIndex(window, remove)
    local index = state.indexes[window:id()]
    if remove then state.indexes[window:id()] = nil end
    return index
  end
  function PaperWM.state.windowList(space, col, row)
    if row then return state.layout[space] and state.layout[space][col] and state.layout[space][col][row] end
    if col then return rowsProxy(space, col) end
    return columnsProxy(space)
  end
  function PaperWM.state.xPositions(space)
    state.xPositionsBySpace[space] = state.xPositionsBySpace[space] or {}
    return state.xPositionsBySpace[space]
  end
  function PaperWM.state.get()
    return { window_list = state.layout, x_positions = state.xPositionsBySpace }
  end
  PaperWM.windows = {
    Direction = { NEXT = 1, PREVIOUS = -1 },
    focusWindow = function()
      if PaperWM.nativeFocusResult then PaperWM.nativeFocusResult:focus() end
      return PaperWM.nativeFocusResult
    end,
    moveWindow = function(window, frame)
      PaperWM.moveCount = PaperWM.moveCount + 1
      window._frame = { x = frame.x, y = frame.y, w = frame.w, h = frame.h }
    end,
  }
  function PaperWM:start()
    self.startCount = self.startCount + 1
    if self.failStart then error("start failed") end
    local rebuilt = {}
    for _, window in pairs(windows) do
      rebuilt[window.space] = rebuilt[window.space] or {}
      table.insert(rebuilt[window.space], { window })
    end
    state.layout = rebuilt
    state.xPositionsBySpace = {}
    rebuildIndexes()
  end

  return {
    hs = hs,
    PaperWM = PaperWM,
    state = state,
    windows = windows,
    recovery = recoveryModule.new(hs, PaperWM),
    rebuildIndexes = rebuildIndexes,
  }
end

test("consistent state is a no-op", function()
  local w1, w2 = newWindow(1, 1, 10), newWindow(2, 1, 720)
  local f = newFixture({ [1] = { { w1 }, { w2 } } })
  assertEqual(f.recovery.windowStateIsConsistent(), true, "state consistency")
  assertEqual(f.recovery.repairWindowState(), true, "repair result")
  assertEqual(f.PaperWM.startCount, 0, "restart count")
end)

test("missing indexes and empty columns are inconsistent", function()
  local w1 = newWindow(1, 1, 10)
  local f = newFixture({ [1] = { { w1 } } })
  f.PaperWM.state.windowIndex(w1, true)
  assertEqual(f.recovery.windowStateIsConsistent(), false, "missing index")
  f.state.layout[1] = { {}, { w1 } }
  f.rebuildIndexes()
  assertEqual(f.recovery.windowStateIsConsistent(), false, "empty column")
end)

test("repair preserves stacks frames and virtual positions", function()
  local w1, w2, w3 = newWindow(1, 1, 10), newWindow(2, 1, 10), newWindow(3, 1, 1200)
  local f = newFixture({ [1] = { { w1, w2 }, { w3 } } })
  f.state.xPositionsBySpace[1][3] = 1800
  f.hs.focused = w1
  f.PaperWM.state.windowIndex(w3, true)
  assertEqual(f.recovery.repairWindowState(), true, "repair result")
  local first = f.PaperWM.state.windowIndex(w1)
  local second = f.PaperWM.state.windowIndex(w2)
  assertEqual(first.col, second.col, "stack column")
  assertEqual(second.row, 2, "stack row")
  assertEqual(f.PaperWM.state.xPositions(1)[3], 1800, "virtual x")
  assertEqual(w3:frame().x, 1200, "physical x")
  assertEqual(f.PaperWM.default_width, 0.62, "default width")
end)

test("repair restores defaults and reports restart errors", function()
  local w1 = newWindow(1, 1, 10)
  local f = newFixture({ [1] = { { w1 } } })
  f.PaperWM.state.windowIndex(w1, true)
  f.PaperWM.failStart = true
  assertEqual(f.recovery.repairWindowState(), false, "repair failure")
  assertEqual(f.PaperWM.default_width, 0.62, "default width after failure")
  assertEqual(#f.PaperWM.errors, 1, "logged errors")
end)

test("native cycling does not wrap", function()
  local w1, w2 = newWindow(1, 1, 10), newWindow(2, 1, 720)
  local f = newFixture({ [1] = { { w1 }, { w2 } } })
  f.hs.focused = w1
  f.PaperWM.nativeFocusResult = w2
  f.recovery.cycleNextWindow()
  assertEqual(f.hs.focused, w2, "native focus target")
  assertEqual(w1.focusCount, 0, "wrap focus count")
end)

test("next and previous wrap across the strip", function()
  local w1, w2, w3 = newWindow(1, 1, 10), newWindow(2, 1, 720), newWindow(3, 1, 720)
  local f = newFixture({ [1] = { { w1 }, { w2, w3 } } })
  f.hs.focused = w3
  f.recovery.cycleNextWindow()
  assertEqual(f.hs.focused, w1, "next wrap")
  f.hs.focused = w1
  f.recovery.cyclePreviousWindow()
  assertEqual(f.hs.focused, w3, "previous wrap")
end)

test("single-window layouts do not refocus", function()
  local w1 = newWindow(1, 1, 10)
  local f = newFixture({ [1] = { { w1 } } })
  f.hs.focused = w1
  f.recovery.cycleNextWindow()
  assertEqual(w1.focusCount, 0, "focus count")
end)

test("wrapped focus retries when macOS steals focus", function()
  local w1, w2 = newWindow(1, 1, 10), newWindow(2, 1, 720)
  local f = newFixture({ [1] = { { w1 }, { w2 } } })
  f.hs.focused = w2
  w1.delayFocus = true
  f.recovery.cycleNextWindow()
  assertEqual(w1.focusCount, 2, "focus attempts")
  assertEqual(f.hs.focused, w1, "retry focus target")
end)

io.write(string.format("PaperWM recovery tests passed (%d).\n", testsRun))
