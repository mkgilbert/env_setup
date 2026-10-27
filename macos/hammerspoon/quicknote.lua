-- Hyper+J: floating box for quick notes, saved to ~/projects/second-brain/import/

local log = hs.logger.new('quicknote', 'info')

local IMPORT_DIR = os.getenv('HOME') .. '/projects/second-brain/import'
local WIDTH, HEIGHT = 560, 240

local HTML = [[
<!doctype html>
<html><head><style>
  html, body { margin: 0; height: 100%; background: #1e1e1e; }
  textarea {
    box-sizing: border-box; width: 100%; height: calc(100% - 24px);
    border: 0; outline: 0; resize: none; padding: 12px;
    background: #1e1e1e; color: #eee; font: 14px Menlo, monospace;
  }
  div { height: 24px; padding: 0 12px; color: #888; font: 11px -apple-system, sans-serif; }
</style></head><body>
<textarea id="t" autofocus placeholder="Quick note..."></textarea>
<div>&#8984;&#8617; save &middot; esc cancel</div>
<script>
  const t = document.getElementById('t');
  const send = (msg) => webkit.messageHandlers.quicknote.postMessage(msg);
  window.addEventListener('focus', () => t.focus());
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') { e.preventDefault(); send({action: 'cancel'}); }
    else if (e.key === 'Enter' && e.metaKey) { e.preventDefault(); send({action: 'save', text: t.value}); }
  });
</script>
</body></html>
]]

local view = nil
local previousWindow = nil
local userContent = nil

function quickNotePath()
  local base = IMPORT_DIR .. '/' .. os.date('%Y-%m-%d %H%M')
  local path = base .. '.md'
  local n = 2
  while hs.fs.attributes(path) do
    path = base .. ' ' .. n .. '.md'
    n = n + 1
  end
  return path
end

function saveQuickNote(text)
  if not text or not text:match('%S') then
    return true
  end
  hs.fs.mkdir(IMPORT_DIR)
  local path = quickNotePath()
  local f, err = io.open(path, 'w')
  if not f then
    log.e('could not write ' .. path .. ': ' .. tostring(err))
    hs.alert.show('Quick note NOT saved: ' .. tostring(err), 4)
    return false
  end
  f:write((text:gsub('%s+$', '')) .. '\n')
  f:close()
  hs.alert.show('Saved to import/', 1)
  return true
end

function closeQuickNote()
  local v = view
  view = nil
  if v then
    hs.timer.doAfter(0, function() v:delete() end)
  end
  if previousWindow then
    previousWindow:focus()
    previousWindow = nil
  end
end

function showQuickNote()
  if view then
    view:hswindow():focus()
    return
  end
  previousWindow = hs.window.focusedWindow()

  userContent = hs.webview.usercontent.new('quicknote'):setCallback(function(msg)
    local body = msg.body
    if body.action == 'save' then
      if saveQuickNote(body.text) then
        closeQuickNote()
      end
    else
      closeQuickNote()
    end
  end)

  local screen = hs.mouse.getCurrentScreen():frame()
  local rect = hs.geometry.rect(
    screen.x + (screen.w - WIDTH) / 2,
    screen.y + (screen.h - HEIGHT) / 3,
    WIDTH, HEIGHT)

  view = hs.webview.new(rect, {}, userContent)
    :windowTitle('Quick note')
    :windowStyle({'titled', 'closable'})
    :level(hs.drawing.windowLevels.floating)
    :allowTextEntry(true)
    :closeOnEscape(false)
    :deleteOnClose(true)
    :windowCallback(function(action)
      if action == 'closing' then
        view = nil
      end
    end)
    :html(HTML)
    :show()

  hs.timer.doAfter(0.05, function()
    if view then
      view:hswindow():focus()
    end
  end)
end

function setUpQuickNote()
  hs.hotkey.bind(HYPER, 'j', showQuickNote)
end
