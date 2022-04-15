-- Mike Solomon @msol 2019
-- customized by mg 2021
spaces = require("hs._asm.undocumented.spaces")
inspect = require("inspect")

-- global variables
local log = hs.logger.new('main', 'debug')
DEVELOPING_THIS = true -- set to true to ease debugging
-- Custom Hyper key bindings (use Karabiner to set these 4 keys to capslock)
HYPER = {'ctrl', 'shift', 'alt', 'cmd'}

-- Get all screens and their positions
screens = hs.screen.screenPositions()
-- figure out which screen is which

for k, v in pairs(screens) do 
  if v["x"] == -1 or v["y"] == 1 then 
      lscreen = k 
  elseif v["x"] == 0 and v["y"] == 0 then 
      cscreen = k 
  else 
      rscreen = k 
  end
end

if lscreen == nil then
  lscreen = cscreen
end

if rscreen == nil then
  rscreen = cscreen
end

-- holds all windows that I care about that are in custom full screen tiled spaces
mySpacesWins = {
  vncScreen = nil,
  [lscreen] = {}, 
  [cscreen] = {}, 
  [rscreen] = {}
}

-- Setup custom installer spoon
hs.loadSpoon("SpoonInstall")
Install = spoon.SpoonInstall
spoon.SpoonInstall.repos.zzspoons = {
  url = "https://github.com/zzamboni/zzSpoons",
  desc = "zzamboni's spoon repository",
}
spoon.SpoonInstall.use_syncinstall = true

-- setup screen info

-- install some custom spoons
Install:andUse("TextClipboardHistory",
               {
                 disable = false,
                 config = {
                   show_in_menubar = false,
                 },
                 hotkeys = {
                   toggle_clipboard = { HYPER, "v" } 
                 },
                 start = true,
               }
)

Install:andUse("KSheet",
               {
                 hotkeys = {
                   toggle = { HYPER, "/" }
                }}
)

-- App bindings
function setUpAppBindings()
  hyperFocusAll('w', '')
  hyperFocusOrOpen('e', 'Microsoft Outlook')
  hyperFocusOrOpen('k', 'KeePassXC')
  hyperFocus('i', 'Firefox')
  hyperFocus('return', 'iTerm2')
  hyperFocusOrOpen('a', 'Finder')
  hyperFocusOrOpen('c', 'Calendar')
  hyperFocusOrOpen('m', 'Mattermost')
  hyperFocusOrOpen('r', '')
  hyperFocus('t', '')
  hyperFocusOrOpen(';', '')
  hyperFocusOrOpen('s', 'Slack')
  hyperFocusOrOpen('g', 'Google Chrome')
  hyperFocusOrOpen('space', 'Visual Studio Code')
  -- apps that I want to open in a full screen space
  hyperFocusOrOpenSpace('x', 'vnc', "center")
end

-- Window management
function setUpWindowManagement()
  hs.window.animationDuration = 0 -- disable animations
  hs.grid.setMargins({0, 0})
  hs.grid.setGrid('2x2')

  function mkSetFocus(to)
    return function() hs.grid.set(hs.window.focusedWindow(), to) end
  end

  function toggleFullScreen()
    return function() 
      local window = hs.window.focusedWindow()
      window:toggleFullScreen()
    end
  end

  local fullScreen = hs.geometry("0,0 2x2")
  local leftHalf = hs.geometry("0,0 1x2")
  local rightHalf = hs.geometry("1,0 1x2")
  local upperLeft = hs.geometry("0,0 1x1")
  local lowerLeft = hs.geometry("0,1 1x1")
  local upperRight = hs.geometry("1,0 1x1")
  local lowerRight = hs.geometry("1,1 1x1")

  hs.hotkey.bind(HYPER, 'f', toggleFullScreen())
  hs.hotkey.bind(HYPER, 'h', mkSetFocus(leftHalf))
  hs.hotkey.bind(HYPER, "'", mkSetFocus(rightHalf))
  hs.hotkey.bind(HYPER, "y", mkSetFocus(upperLeft))
  hs.hotkey.bind(HYPER, "b", mkSetFocus(lowerLeft))
  hs.hotkey.bind(HYPER, "u", mkSetFocus(upperRight))
  hs.hotkey.bind(HYPER, "n", mkSetFocus(lowerRight))

  hs.hotkey.bind(HYPER, "up", hs.window.filter.focusNorth)
  hs.hotkey.bind(HYPER, "down", hs.window.filter.focusSouth)
  hs.hotkey.bind(HYPER, "left", hs.window.filter.focusWest)
  hs.hotkey.bind(HYPER, "right", hs.window.filter.focusEast)
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

function hyperFocusOrOpenSpace(key, app, screen)
  hs.hotkey.bind(HYPER, key, mkFocusOrOpenSpaceWin(app, screen))
end

-- focus to the space win that is saved in mySpaceWins on the specific screen
-- supports VNC Viewer, Firefox, and iTerm2
function mkFocusOrOpenSpaceWin(appName, screen)
  return function()
    if screen == nil or screen == "center" then
      screen = cscreen
    elseif screen == "left" then
      screen = lscreen
    elseif screen == "right" then
      screen = rscreen
    else
      log.e("Screen ", screen, " not found")
    end
    log:d("screen: ", screen)
    -- vnc can only have one instance, so only one screen is possible
    if appName == "vnc" then
      screen = mySpacesWins.vncScreen
      if screen == nil then
        hs.application.launchOrFocus("VNC Viewer")
        return true
      end
    end
    log:d("spaces Animating: ", cscreen:spacesAnimating())
    if mySpacesWins[screen][appName] ~= nil then
      mySpacesWins[screen][appName]:focus()
    else
      log:d("No window found")
    end
  end
end

-- Find and save the firefox, iterm, and vnc windows that are inside of their own spaces in a table
function findAndSaveSpaceWins()
  log:d("Scanning all Spaces")
  for screenUUID, spaceIDsOnDisplay in pairs(spaces.layout()) do
    -- figure out which screen it is
    -- repeat .. do break end ... until true is the Lua equiv of "continue"
    repeat
      log:d("Found screen " .. hs.screen.find(screenUUID):name())
      if screenUUID == cscreen:getUUID() then
        currScreen = cscreen
        log:d("currScreen is cscreen")
      elseif screenUUID == lscreen:getUUID() then
        currScreen = lscreen
        log:d("currScreen is lscreen")
      elseif screenUUID == rscreen:getUUID() then
        currScreen = rscreen
        log:d("currScreen is rscreen")
      else
        log:d("Error setting screen. Found an unknown screen")
        do break end
      end

    for _, spaceID in pairs(spaceIDsOnDisplay) do
      log:d(spaceID)
      if spaces.spaceType(spaceID) == spaces.types["tiled"] then
        wins = spaces.allWindowsForSpace(spaceID)
        for k, v in pairs(wins) do
          log:d("Found " .. v:application():name() ..  " window on " .. currScreen:name())
          if v:application():name() == "Firefox" then
            mySpacesWins[currScreen].Firefox = v
          elseif v:application():name() == "iTerm2" then
            mySpacesWins[currScreen].iTerm2 = v
          elseif v:application():name() == "VNC Viewer" then
            mySpacesWins[currScreen].vnc = v
            mySpacesWins.vncScreen = currScreen
          end
        end
      end
    end
    until true
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

-- "objects" in lua are really just tables (i.e. dicts), and there isn't a
-- built-in way to print them for debugging. That's what this function is for
function dump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then 
          k = '"'..tostring(k)..'"' 
        end
        s = s .. '  ['..k..'] = ' .. dump(v) .. ',\n'
     end
     return s .. '} '
  else
     return tostring(o)
  end
end

-- just returns the number of items in a table object
function tableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

-- Main
maybeEnableDebug()
findAndSaveSpaceWins()
setUpAppBindings()
setUpWindowManagement()