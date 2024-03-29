-- Mike Solomon @msol 2019

local log = hs.logger.new('main', 'info')
DEVELOPING_THIS = false -- set to true to ease debugging

HYPER = {'ctrl', 'shift', 'alt', 'cmd'}

-- App bindings
function setUpAppBindings()
  --hyperFocusAll('w', 'React Native Debugger', 'Simulator', 'qemu-system-x86_64')
  hyperFocusOrOpen('e', 'emacs')
  hyperFocus('i', 'Google Chrome')
  hyperFocusOrOpen('a', 'Finder')
  hyperFocusOrOpen('c', 'Calendar')
  hyperFocusOrOpen('m', 'Spotify')
  hyperFocusOrOpen('s', 'Slack')
  hyperFocusOrOpen('z', 'zoom.us')
  hyperFocusOrOpen('t', 'Notes')
  hyperFocusOrOpen('p', 'Pomatez')
  hyperFocusOrOpen('RETURN', 'iTerm2')
  --hyperFocusOrOpen('s', 'OmniFocus')
  --hyperFocus('f', 'Google Chrome', 'Firefox')
  hyperFocusOrOpen('space', 'Visual Studio Code')
end

-- Window management
function setUpWindowManagement()
  hs.window.animationDuration = 0 -- disable animations
  hs.grid.setMargins({0, 0})
  hs.grid.setGrid('2x2')

  function mkSetFocus(to)
    return function() hs.grid.set(hs.window.focusedWindow(), to) end
  end

  function setRealFullScreen()
    local win = hs.window.focusedWindow()
    if win ~= nil then
        win:setFullScreen(not win:isFullScreen())
    end
  end

  -- window positions: format is "X,Y WxH", where X,Y is the starting coord and 2x2 represents
  -- the full size of the screen
  local fullScreen = hs.geometry("0,0 2x2")
  local leftHalf = hs.geometry("0,0 1x2")
  local rightHalf = hs.geometry("1,0 1x2")
  local upperLeft = hs.geometry("0,0 1x1")
  local lowerLeft = hs.geometry("0,1 1x1")
  local upperRight = hs.geometry("1,0 1x1")
  local lowerRight = hs.geometry("1,1 1x1")
  local upperHalf = hs.geometry("0,0 2x1")
  local lowerHalf = hs.geometry("0,1 2x1")

  hs.hotkey.bind(HYPER, 'f', setRealFullScreen)
  hs.hotkey.bind(HYPER, 'l', mkSetFocus(fullScreen))
  hs.hotkey.bind(HYPER, 'h', mkSetFocus(leftHalf))
  hs.hotkey.bind(HYPER, "'", mkSetFocus(rightHalf))
  hs.hotkey.bind(HYPER, "y", mkSetFocus(upperLeft))
  hs.hotkey.bind(HYPER, "b", mkSetFocus(lowerLeft))
  hs.hotkey.bind(HYPER, "u", mkSetFocus(upperRight))
  hs.hotkey.bind(HYPER, "n", mkSetFocus(lowerRight))
  hs.hotkey.bind(HYPER, "[", mkSetFocus(upperHalf))
  hs.hotkey.bind(HYPER, "]", mkSetFocus(lowerHalf))

  hs.hotkey.bind(HYPER, "up", hs.window.filter.focusNorth)
  hs.hotkey.bind(HYPER, "down", hs.window.filter.focusSouth)
  hs.hotkey.bind(HYPER, "left", hs.window.filter.focusWest)
  hs.hotkey.bind(HYPER, "right", hs.window.filter.focusEast)
  -- hs.hotkey.bind(HYPER, "v", hs.window.filter.focusNorth)
  -- hs.hotkey.bind(HYPER, "c", hs.window.filter.focusSouth)
  -- hs.hotkey.bind(HYPER, "j", hs.window.filter.focusWest)
  -- hs.hotkey.bind(HYPER, "p", hs.window.filter.focusEast)
  hs.hotkey.bind(HYPER, "q", hs.hints.windowHints)
  -- HYPER "d" -- Bound in Karabiner to Cmd+Tab (application switcher)
  -- HYPER "k" -- Bound in Karabiner to Cmd+` (next window of application)

  -- throw to other screen
  hs.hotkey.bind(HYPER, 'o', function()
    local window = hs.window.focusedWindow()
    window:moveToScreen(window:screen():next())
  end)
end

-- focus on the last-focused window of the application given by name, or else launch it
function hyperFocusOrOpen(key, app)
  local focus = mkFocusByPreferredApplicationTitle(true, app)
  function focusOrOpen()
    return (focus() or hs.application.launchOrFocus(app))
  end
  hs.hotkey.bind(HYPER, key, focusOrOpen)
end

-- focus on the last-focused window of the first application given by name
function hyperFocus(key, ...)
  hs.hotkey.bind(HYPER, key, mkFocusByPreferredApplicationTitle(true, ...))
end


-- focus on the last-focused window of every application given by name
function hyperFocusAll(key, ...)
  hs.hotkey.bind(HYPER, key, mkFocusByPreferredApplicationTitle(false, ...))
end


-- creates callback function to select application windows by application name
function mkFocusByPreferredApplicationTitle(stopOnFirst, ...)
  local arguments = {...} -- create table to close over variadic args
  return function()
    local nowFocused = hs.window.focusedWindow()
    local appFound = false
    for _, app in ipairs(arguments) do
      if stopOnFirst and appFound then break end
      log:d('Searching for app ', app)
      local application = hs.application.get(app)
      if application ~= nil then
        log:d('Found app', application)
        local window = application:mainWindow()
        if window ~= nil then
          log:d('Found main window', window)
          if window == nowFocused then
            log:d('Already focused, moving on', application)
          else
            window:focus()
            appFound = true
          end
        end
      end
    end
    return appFound
  end
end


function maybeEnableDebug()
  if DEVELOPING_THIS then
    log.setLogLevel('debug')
    log.d('Loading in development mode')
    -- automatically reload changes when we're developing
    hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
    hs.alert('Hammerspoon config reloaded')
    log:d('Hammerspoon config reloaded')
  end
end

function setUpClipboardTool()
  ClipboardTool = hs.loadSpoon('ClipboardTool')
  ClipboardTool.show_in_menubar = true
  ClipboardTool:start()
  ClipboardTool:bindHotkeys({
    toggle_clipboard = {HYPER, "v"}
  })
end

-- Main

maybeEnableDebug()
setUpAppBindings()
setUpWindowManagement()
setUpClipboardTool()
