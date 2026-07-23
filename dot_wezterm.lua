-- ~/.wezterm.lua
-- One Dark 主題 + 接近 Warp 的觀感；跨 macOS / Linux 通用（由 chezmoi 同步）
local wezterm = require 'wezterm'
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- === 平台偵測 ===
local is_mac = wezterm.target_triple:find 'darwin' ~= nil

-- 修飾鍵：macOS 用 Cmd；Linux 沒有 Cmd（會被 WM 搶），改用終端機慣例的 Ctrl+Shift / Ctrl+Alt
local MOD  = is_mac and 'CMD'       or 'CTRL|SHIFT'  -- 主修飾鍵（分割、關閉 pane）
local MOD2 = is_mac and 'CMD|SHIFT' or 'CTRL|ALT'   -- 次修飾鍵（上下分割、Quick Select、分頁清單、pane 導覽）
local LINK_MOD = is_mac and 'CMD' or 'CTRL'          -- 點擊開連結

-- 找出 mise 執行檔（各平台安裝路徑不同）
local function find_mise()
  local home = os.getenv 'HOME' or ''
  local candidates = {
    '/opt/homebrew/bin/mise',       -- macOS (Apple Silicon Homebrew)
    '/usr/local/bin/mise',          -- macOS (Intel) / Linux
    home .. '/.local/bin/mise',     -- Linux 常見安裝路徑
    '/usr/bin/mise',                -- Linux 套件管理器
  }
  for _, p in ipairs(candidates) do
    local f = io.open(p, 'r')
    if f then f:close(); return p end
  end
  return 'mise'  -- 都找不到就賭它在 PATH 上
end
local mise_bin = find_mise()

-- === 配色：Atom One Dark ===
config.colors = {
  foreground = '#abb2bf',
  background = '#1c1f24',

  cursor_bg = '#528bff',
  cursor_fg = '#1c1f24',
  cursor_border = '#528bff',

  selection_fg = '#abb2bf',
  selection_bg = '#3e4451',

  scrollbar_thumb = '#3e4451',
  split = '#181a1f',

  ansi = {
    '#282c34', -- black
    '#e06c75', -- red
    '#98c379', -- green
    '#e5c07b', -- yellow
    '#61afef', -- blue
    '#c678dd', -- magenta
    '#56b6c2', -- cyan
    '#abb2bf', -- white
  },
  brights = {
    '#5c6370', -- bright black
    '#e06c75', -- bright red
    '#98c379', -- bright green
    '#d19a66', -- bright yellow (orange)
    '#61afef', -- bright blue
    '#c678dd', -- bright magenta
    '#56b6c2', -- bright cyan
    '#ffffff', -- bright white
  },

  -- 分頁列配色（fancy tab bar）
  tab_bar = {
    background = '#16181d',
    active_tab   = { bg_color = '#1c1f24', fg_color = '#abb2bf' },
    inactive_tab = { bg_color = '#16181d', fg_color = '#5c6370' },
    inactive_tab_hover = { bg_color = '#2c313a', fg_color = '#abb2bf' },
    new_tab       = { bg_color = '#16181d', fg_color = '#5c6370' },
    new_tab_hover = { bg_color = '#2c313a', fg_color = '#abb2bf' },
  },
}

-- === 外觀 ===
config.font = wezterm.font_with_fallback {
  'Hack Nerd Font',
  'Hack',
  'JetBrains Mono',
  'DejaVu Sans Mono',  -- Linux 常見
  'Menlo',             -- macOS 內建
  'monospace',
}
config.font_size = 13.0
config.line_height = 1.1

config.window_background_opacity = 1.0
if is_mac then
  config.macos_window_background_blur = 0
end

config.window_decorations = 'RESIZE'  -- 隱藏標題列、保留可調整大小
config.window_padding = { left = 12, right = 12, top = 10, bottom = 8 }

config.use_fancy_tab_bar = true
-- 分頁列文字大小（fancy tab bar 專用，與終端機 font_size 分開）
config.window_frame = {
  font = wezterm.font { family = 'Hack Nerd Font', weight = 'Regular' },
  font_size = 14.0,
}
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32

config.cursor_blink_rate = 500
config.default_cursor_style = 'BlinkingBar'

config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.audible_bell = 'Disabled'

-- === 狀態列：在分頁列右側顯示當前目錄的 node 版本（由 mise 解析）===
local node_cache = { cwd = nil, ver = nil }

wezterm.on('update-status', function(window, pane)
  -- 取得當前工作目錄（pane 關閉瞬間可能抓不到，用 pcall 保護避免噴錯）
  local ok_cwd, cwd_uri = pcall(function() return pane:get_current_working_dir() end)
  if not ok_cwd then return end
  local cwd = nil
  if cwd_uri then
    if type(cwd_uri) == 'userdata' then
      cwd = cwd_uri.file_path            -- 新版 WezTerm 回傳 Url 物件
    else
      cwd = tostring(cwd_uri):gsub('^file://[^/]*', '')  -- 舊版回傳字串
    end
  end

  -- 依 cwd 查 node 版本，同一目錄用快取避免每秒開子行程
  local ver = nil
  if cwd then
    if node_cache.cwd == cwd then
      ver = node_cache.ver
    else
      -- 用 $1 傳入路徑，避免路徑含空白的引號問題
      local ok, success, stdout = pcall(wezterm.run_child_process, {
        '/bin/sh', '-c',
        'cd "$1" && ' .. mise_bin .. ' current node 2>/dev/null',
        'sh', cwd,
      })
      if ok and success and stdout then
        ver = stdout:gsub('%s+', '')
      end
      node_cache.cwd = cwd
      node_cache.ver = ver
    end
  end

  if ver and ver ~= '' then
    window:set_right_status(wezterm.format {
      { Foreground = { Color = '#98c379' } },  -- One Dark 綠
      { Text = ' \u{e718} ' .. ver .. '  ' },
    })
  else
    window:set_right_status ''
  end
end)

-- === 快捷鍵（依平台自動切換修飾鍵）===
-- macOS：Cmd / Cmd+Shift / Cmd+Alt
-- Linux：Ctrl+Shift / Ctrl+Alt（避開 shell 的 Ctrl 與 WM 的 Super）
config.keys = {
  -- 左右分割（新 pane 在右邊）
  { key = 'd', mods = MOD,  action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- 上下分割（新 pane 在下面）
  { key = 'd', mods = MOD2, action = wezterm.action.SplitVertical   { domain = 'CurrentPaneDomain' } },
  -- 關閉目前 pane（不詢問）
  { key = 'w', mods = MOD,  action = wezterm.action.CloseCurrentPane { confirm = false } },
  -- Quick Select（標記畫面上的網址/路徑/hash 快速複製）；內建 Ctrl+Shift+Space 亦可用
  { key = 'u', mods = MOD2, action = wezterm.action.QuickSelect },
  -- 叫出分頁清單，按 / 可過濾/搜尋分頁（右鍵選單的 filter tab）
  { key = 't', mods = MOD2, action = wezterm.action.ShowTabNavigator },
  -- 在 pane 之間移動焦點
  { key = 'LeftArrow',  mods = MOD2, action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = MOD2, action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = MOD2, action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = MOD2, action = wezterm.action.ActivatePaneDirection 'Down' },
}

-- === 滑鼠：修飾鍵+點擊開啟連結（macOS=Cmd，Linux=Ctrl）===
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = LINK_MOD,
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = LINK_MOD,
    action = wezterm.action.Nop,
  },
}

return config
