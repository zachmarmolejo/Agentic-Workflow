local M = {}

function M.new(hs, PaperWM)
  local function focusWithRetry(window)
    window:focus()
    hs.timer.doAfter(hs.window.animationDuration, function()
      local focusedWindow = hs.window.focusedWindow()
      if not focusedWindow or focusedWindow:id() ~= window:id() then
        window:focus()
      end
    end)
  end

  local function windowStateIsConsistent()
    local managedWindows = {}

    for _, window in ipairs(PaperWM.window_filter:getWindows()) do
      if not PaperWM.floating.isFloating(window) and not window:isFullScreen() then
        managedWindows[window:id()] = window
        local index = PaperWM.state.windowIndex(window)
        local trackedWindow = index and PaperWM.state.windowList(index.space, index.col, index.row)
        local windowSpace = hs.spaces.windowSpaces(window)[1]
        if not index or index.space ~= windowSpace
          or not trackedWindow or trackedWindow:id() ~= window:id() then
          return false
        end
      end
    end

    for space, columns in pairs(PaperWM.state.get().window_list) do
      for col, rows in ipairs(columns) do
        if #rows == 0 then
          return false
        end
        for row, window in ipairs(rows) do
          local index = PaperWM.state.windowIndex(window)
          if not managedWindows[window:id()] or not index
            or index.space ~= space or index.col ~= col or index.row ~= row then
            return false
          end
        end
      end
    end

    return true
  end

  local function repairWindowState()
    if windowStateIsConsistent() then
      return true
    end

    local focusedWindow = hs.window.focusedWindow()
    local savedWindows = {}
    local savedFrames = {}
    local savedXPositions = {}
    for _, window in ipairs(PaperWM.window_filter:getWindows()) do
      if not PaperWM.floating.isFloating(window) and not window:isFullScreen() then
        local id = window:id()
        local index = PaperWM.state.windowIndex(window)
        savedWindows[id] = window
        savedFrames[id] = window:frame()
        if index then
          savedXPositions[id] = {
            space = index.space,
            x = PaperWM.state.xPositions(index.space)[id],
          }
        else
          for space, positions in pairs(PaperWM.state.get().x_positions) do
            if positions[id] ~= nil then
              savedXPositions[id] = { space = space, x = positions[id] }
              break
            end
          end
        end
      end
    end

    local savedStacks = {}
    local stackedWindowIDs = {}
    for _, columns in pairs(PaperWM.state.get().window_list) do
      for _, rows in ipairs(columns) do
        local stack = {}
        for _, window in ipairs(rows) do
          local id = window:id()
          if savedWindows[id] and not stackedWindowIDs[id] then
            table.insert(stack, id)
            stackedWindowIDs[id] = true
          end
        end
        if #stack > 1 then
          table.insert(savedStacks, stack)
        end
      end
    end

    local defaultWidth = PaperWM.default_width
    PaperWM.default_width = nil
    local ok, err = xpcall(function()
      PaperWM.events.stop()
      PaperWM:start()

      for _, stack in ipairs(savedStacks) do
        local firstWindow = savedWindows[stack[1]]
        for row = 2, #stack do
          local window = savedWindows[stack[row]]
          local firstIndex = PaperWM.state.windowIndex(firstWindow)
          local index = PaperWM.state.windowIndex(window)
          if firstIndex and index and index.space == firstIndex.space and index.col ~= firstIndex.col then
            local sourceColumn = PaperWM.state.windowList(index.space, index.col)
            local removedWindow = table.remove(sourceColumn, index.row)
            firstIndex = PaperWM.state.windowIndex(firstWindow)
            table.insert(PaperWM.state.windowList(firstIndex.space, firstIndex.col), removedWindow)
          end
        end
      end

      for id, frame in pairs(savedFrames) do
        local window = savedWindows[id]
        local index = PaperWM.state.windowIndex(window)
        if index then
          PaperWM.windows.moveWindow(window, frame)
          local savedPosition = savedXPositions[id]
          local x = savedPosition and savedPosition.space == index.space and savedPosition.x or frame.x
          PaperWM.state.xPositions(index.space)[id] = x
        end
      end

      if not windowStateIsConsistent() then
        error("PaperWM window state remained inconsistent after rebuilding")
      end
    end, debug.traceback)
    PaperWM.default_width = defaultWidth
    if not ok then
      PaperWM.logger.e(err)
      return false
    end
    if focusedWindow then
      focusWithRetry(focusedWindow)
    end
    return true
  end

  local function edgeWindow(columns, direction)
    if direction == PaperWM.windows.Direction.NEXT then
      for col = 1, #columns do
        if columns[col] and #columns[col] > 0 then
          return columns[col][1]
        end
      end
    else
      for col = #columns, 1, -1 do
        if columns[col] and #columns[col] > 0 then
          return columns[col][#columns[col]]
        end
      end
    end
  end

  local function cycleWindow(direction)
    if not repairWindowState() then
      return
    end

    local focusedWindow = hs.window.focusedWindow()
    local focusedIndex = focusedWindow and PaperWM.state.windowIndex(focusedWindow)
    if not focusedIndex then
      return
    end

    if PaperWM.windows.focusWindow(direction, focusedIndex) then
      return
    end

    local targetWindow = edgeWindow(PaperWM.state.windowList(focusedIndex.space), direction)
    if not targetWindow or targetWindow:id() == focusedWindow:id() then
      return
    end

    focusWithRetry(targetWindow)
  end

  return {
    windowStateIsConsistent = windowStateIsConsistent,
    repairWindowState = repairWindowState,
    cycleNextWindow = function()
      cycleWindow(PaperWM.windows.Direction.NEXT)
    end,
    cyclePreviousWindow = function()
      cycleWindow(PaperWM.windows.Direction.PREVIOUS)
    end,
  }
end

return M
