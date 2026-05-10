local colors   = require("colors")
local icons    = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- ══════════════════════════════════════════════════════════════════
--  OmniWM CLI helpers
-- ══════════════════════════════════════════════════════════════════

local CMD = {
  displays   = "omniwmctl query displays   --format json",
  workspaces = "omniwmctl query workspaces --format json",
  windows    = "omniwmctl query windows    --workspace %s --format json",
  focused_ws = "omniwmctl query workspaces --focused    --format json",
  switch     = "omniwmctl workspace focus-name %s",
}

-- ══════════════════════════════════════════════════════════════════
--  Module state
-- ══════════════════════════════════════════════════════════════════

local spaces   = {}   -- [spaceId] = { item, bracket, name, display }
local icon_cache = {}

-- ══════════════════════════════════════════════════════════════════
--  Helpers
-- ══════════════════════════════════════════════════════════════════

local function app_icon(name)
  if icon_cache[name] then return icon_cache[name] end
  local ic = app_icons[name] or app_icons["Default"]
  icon_cache[name] = ic
  return ic
end

-- Safely decode JSON output; returns nil on failure.
local function decode(raw)
  if not raw or raw == "" then return nil end
  local ok, val = pcall(function() return sbar.json(raw) end)
  return ok and val or nil
end

-- Build spaceId key from workspace name + display id.
local function space_key(ws_name, display_id)
  return "ws_" .. ws_name .. "__d" .. tostring(display_id)
end

-- ══════════════════════════════════════════════════════════════════
--  Icon strip
-- ══════════════════════════════════════════════════════════════════

local function update_icons(space_id, ws_name)
  sbar.exec(CMD.windows:format(ws_name), function(raw)
    local data = decode(raw)
    if not data then return end

    local strip = ""
    local has   = false

    -- data is a list of window objects; field is "app"
    for _, win in ipairs(data) do
      local name = win.app or ""
      if name ~= "" then
        strip = strip .. " " .. app_icon(name)
        has = true
      end
    end

    local s = spaces[space_id]
    if s then
      s.item:set({ label = { string = strip, drawing = has } })
    end
  end)
end

-- ══════════════════════════════════════════════════════════════════
--  Item creation
-- ══════════════════════════════════════════════════════════════════

local function create_item(space_id, ws_name, display_id)
  local item = sbar.add("item", space_id, {
    icon = {
      font          = { family = settings.font.numbers },
      string        = ws_name,
      padding_left  = 12,
      padding_right = 12,
      color         = colors.white,
      highlight_color = colors.yellow,
    },
    label = {
      padding_right = 14,
      padding_left  = 0,
      color         = colors.grey,
      highlight_color = colors.yellow,
      font          = "sketchybar-app-font:Regular:12.0",
      y_offset      = -1,
    },
    padding_left  = 2,
    padding_right = 2,
    background = {
      color         = colors.bg1,
      border_width  = 1,
      height        = 26,
      border_color  = colors.grey,
      corner_radius = 9,
    },
    click_script = CMD.switch:format(ws_name),
    display      = display_id,
  })

  local bracket = sbar.add("bracket", { space_id }, {
    background = {
      color         = colors.transparent,
      border_color  = colors.transparent,
      height        = 26,
      border_width  = 1,
      corner_radius = 9,
    },
  })

  item:subscribe("mouse.clicked", function()
    sbar.exec(CMD.switch:format(ws_name))
  end)

  spaces[space_id] = {
    item    = item,
    bracket = bracket,
    name    = ws_name,
    display = display_id,
  }
end

-- ══════════════════════════════════════════════════════════════════
--  Appearance
-- ══════════════════════════════════════════════════════════════════

local function set_appearance(space_id, selected)
  local s = spaces[space_id]
  if not s then return end

  s.item:set({
    icon  = { highlight = selected },
    label = { highlight = selected },
  })
  s.bracket:set({
    background = {
      border_color = selected and colors.dirty_white or colors.transparent,
    },
  })
end

-- ══════════════════════════════════════════════════════════════════
--  Remove stale items
-- ══════════════════════════════════════════════════════════════════

local function remove_item(space_id)
  local s = spaces[space_id]
  if not s then return end
  sbar.remove(s.item)
  sbar.remove(s.bracket)
  spaces[space_id] = nil
end

-- ══════════════════════════════════════════════════════════════════
--  Main refresh
-- ══════════════════════════════════════════════════════════════════

local function refresh()
  -- 1. Grab workspaces JSON (includes display id and focus state)
  sbar.exec(CMD.workspaces, function(raw)
    local ws_list = decode(raw)
    if not ws_list then return end

    -- OmniWM returns a list of workspace objects.
    -- Relevant fields: raw-name, display (id), is-focused, is-visible
    local seen = {}

    for _, ws in ipairs(ws_list) do
      local ws_name    = ws["raw-name"] or ws["display-name"] or ""
      local display_id = ws["display"]  or 1
      local focused    = ws["is-focused"] == true

      if ws_name == "" then goto continue end

      local sid = space_key(ws_name, display_id)
      seen[sid] = true

      if not spaces[sid] then
        create_item(sid, ws_name, display_id)
      end

      set_appearance(sid, focused)
      update_icons(sid, ws_name)

      ::continue::
    end

    -- Remove items that are no longer reported by OmniWM
    for sid in pairs(spaces) do
      if not seen[sid] then
        remove_item(sid)
      end
    end
  end)
end

-- ══════════════════════════════════════════════════════════════════
--  Bootstrap
-- ══════════════════════════════════════════════════════════════════

refresh()

-- ══════════════════════════════════════════════════════════════════
--  Subscription observer  (hidden item, never drawn)
-- ══════════════════════════════════════════════════════════════════
--
--  OmniWM fires events via:
--    omniwmctl watch active-workspace,windows-changed,focus \
--      --exec sketchybar --trigger omniwm_update
--
--  Add that watch command to your OmniWM startup / login item.
--  The events below cover every case the aerospace version handled.

local observer = sbar.add("item", "omniwm_observer", {
  drawing = false,
  updates = true,
})

observer:subscribe({
  "omniwm_update",      -- our custom trigger from omniwmctl watch
  "front_app_switched", -- sketchybar built-in (fallback)
  "space_change",       -- sketchybar built-in (fallback)
}, function()
  refresh()
end)

-- ══════════════════════════════════════════════════════════════════
--  Spaces indicator  (toggle menus ↔ spaces)
-- ══════════════════════════════════════════════════════════════════

local indicator = sbar.add("item", "spaces_indicator", {
  padding_left  = -3,
  padding_right = 0,
  icon = {
    padding_left  = 8,
    padding_right = 9,
    color         = colors.grey,
    string        = icons.switch.on,
  },
  label = {
    width         = 0,
    padding_left  = 0,
    padding_right = 8,
    string        = "Spaces",
    color         = colors.bg1,
  },
  background = {
    color        = colors.with_alpha(colors.grey, 0.0),
    border_color = colors.with_alpha(colors.bg1, 0.0),
  },
})

indicator:subscribe("swap_menus_and_spaces", function()
  local on = indicator:query().icon.value == icons.switch.on
  indicator:set({ icon = { string = on and icons.switch.off or icons.switch.on } })
end)

indicator:subscribe("mouse.entered", function()
  sbar.animate("tanh", 30, function()
    indicator:set({
      background = {
        color        = { alpha = 1.0 },
        border_color = { alpha = 0.5 },
      },
      icon  = { color = colors.bg1 },
      label = { width = "dynamic" },
    })
  end)
end)

indicator:subscribe("mouse.exited", function()
  sbar.animate("tanh", 30, function()
    indicator:set({
      background = {
        color        = { alpha = 0.0 },
        border_color = { alpha = 0.0 },
      },
      icon  = { color = colors.grey },
      label = { width = 0 },
    })
  end)
end)

indicator:subscribe("mouse.clicked", function()
  sbar.trigger("swap_menus_and_spaces")
end)
