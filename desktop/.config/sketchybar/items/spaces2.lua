-- ══════════════════════════════════════════════════════════════════
--  spaces.lua  –  OmniWM workspace bar for sketchybar / SbarLua
--
--  SETUP: add these two watchers to your OmniWM startup script:
--
--    # 1. workspace focus changed  (cheap: no payload needed)
--    omniwmctl watch active-workspace --no-send-initial \
--      --exec sketchybar --trigger omniwm_focus &
--
--    # 2. window inventory changed (open / close / move between ws)
--    omniwmctl watch windows-changed --no-send-initial \
--      --exec sketchybar --trigger omniwm_windows &
--
-- ══════════════════════════════════════════════════════════════════

local colors    = require("colors")
local icons     = require("icons")
local settings  = require("settings")
local app_icons = require("helpers.app_icons")

-- ──────────────────────────────────────────────────────────────────
--  Unicode superscripts for window counts  (2+ windows, same app)
-- ──────────────────────────────────────────────────────────────────
local SUPER = { "", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹" }

local function superscript(n)
  if n <= 1 then return "" end
  return SUPER[n] or "⁺"
end

-- ──────────────────────────────────────────────────────────────────
--  App icon helper  (memoised)
-- ──────────────────────────────────────────────────────────────────
local icon_cache = {}

local function app_icon(name)
  if not icon_cache[name] then
    icon_cache[name] = app_icons[name] or app_icons["Default"]
  end
  return icon_cache[name]
end

-- ──────────────────────────────────────────────────────────────────
--  Build icon strip from a list of window objects {app="...", ...}
--
--  Rules:
--   • Deduplicate by app name (preserve first-seen order)
--   • count = 1  →  just the icon          e.g.  
--   • count = 2  →  icon + superscript     e.g.  ²
--   • count > 9  →  icon + ⁺
-- ──────────────────────────────────────────────────────────────────
local function build_strip(windows)
  local counts = {}
  local order  = {}

  for _, win in ipairs(windows) do
    local name = (win.app or ""):match("^%s*(.-)%s*$")
    if name ~= "" then
      if not counts[name] then
        counts[name] = 0
        table.insert(order, name)
      end
      counts[name] = counts[name] + 1
    end
  end

  local strip = ""
  for _, name in ipairs(order) do
    strip = strip .. " " .. app_icon(name) .. superscript(counts[name])
  end

  return strip, #order > 0
end

-- ══════════════════════════════════════════════════════════════════
--  Module state
--
--  ws_state[ws_name] = {
--    item    = <sbar item>,
--    bracket = <sbar bracket>,
--    display = <display id>,
--    focused = <bool>,
--    strip   = <string>,   ← last rendered strip (for diffing)
--  }
-- ══════════════════════════════════════════════════════════════════
local ws_state   = {}
local focused_ws = nil

-- ──────────────────────────────────────────────────────────────────
--  Low-level render: highlight state (NO queries)
-- ──────────────────────────────────────────────────────────────────
local function render_highlight(ws_name, focused)
  local s = ws_state[ws_name]
  if not s then return end
  s.focused = focused
  s.item:set({
    icon  = { highlight = focused },
    label = { highlight = focused },
  })
  s.bracket:set({
    background = {
      border_color = focused and colors.dirty_white or colors.transparent,
    },
  })
end

-- ──────────────────────────────────────────────────────────────────
--  Low-level render: icon strip (NO queries)
-- ──────────────────────────────────────────────────────────────────
local function render_strip(ws_name, strip, has_windows)
  local s = ws_state[ws_name]
  if not s then return end
  s.strip = strip
  s.item:set({
    label = { string = strip, drawing = has_windows },
  })
end

-- ──────────────────────────────────────────────────────────────────
--  Create one workspace item + bracket
-- ──────────────────────────────────────────────────────────────────
local function create_item(ws_name, display_id)
  local id   = "ws_" .. ws_name
  local item = sbar.add("item", id, {
    icon = {
      font            = { family = settings.font.numbers },
      string          = ws_name,
      padding_left    = 12,
      padding_right   = 12,
      color           = colors.white,
      highlight_color = colors.yellow,
    },
    label = {
      padding_right   = 14,
      padding_left    = 0,
      color           = colors.grey,
      highlight_color = colors.yellow,
      font            = "sketchybar-app-font:Regular:12.0",
      y_offset        = -1,
      drawing         = false,
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
    display = display_id,
  })

  local bracket = sbar.add("bracket", { id }, {
    background = {
      color         = colors.transparent,
      border_color  = colors.transparent,
      height        = 26,
      border_width  = 1,
      corner_radius = 9,
    },
  })

  item:subscribe("mouse.clicked", function()
    sbar.exec("omniwmctl workspace focus-name " .. ws_name)
  end)

  ws_state[ws_name] = {
    item    = item,
    bracket = bracket,
    display = display_id,
    focused = false,
    strip   = "",
  }
end

local function remove_item(ws_name)
  local s = ws_state[ws_name]
  if not s then return end
  sbar.remove(s.item)
  sbar.remove(s.bracket)
  ws_state[ws_name] = nil
end

-- ══════════════════════════════════════════════════════════════════
--  Bootstrap  –  runs once at startup (and when workspace set
--  changes dynamically, e.g. a new workspace created/destroyed)
-- ══════════════════════════════════════════════════════════════════
local function bootstrap()
  -- Single query returns all workspaces with display + focus state
  sbar.exec("omniwmctl query workspaces --format json", function(ws_list)
    if type(ws_list) ~= "table" then return end

    local seen = {}

    for _, ws in ipairs(ws_list) do
      local name    = ws["raw-name"] or ws["display-name"] or ""
      local disp    = ws["display"]    or 1
      local focused = ws["is-focused"] == true

      if name == "" then goto continue end
      seen[name] = true

      if not ws_state[name] then
        create_item(name, disp)
      end

      if focused then focused_ws = name end
      render_highlight(name, focused)

      -- Kick off icon query for each workspace in parallel.
      -- sbar.exec is truly async so these all fly concurrently.
      sbar.exec(
        "omniwmctl query windows --workspace " .. name .. " --format json",
        function(wins)
          if type(wins) ~= "table" then return end
          local strip, has = build_strip(wins)
          render_strip(name, strip, has)
        end
      )

      ::continue::
    end

    -- Remove items for workspaces OmniWM no longer reports
    for name in pairs(ws_state) do
      if not seen[name] then remove_item(name) end
    end
  end)
end

-- ══════════════════════════════════════════════════════════════════
--  Event: omniwm_focus
--  Source: omniwmctl watch active-workspace
--  Cost: 1 cheap query to get new focused workspace name,
--        then just two :set() calls – no icon work at all.
-- ══════════════════════════════════════════════════════════════════
sbar.add("event", "omniwm_focus")

sbar.add("item", "omniwm_focus_obs", { drawing = false, updates = true })
  :subscribe("omniwm_focus", function(_env)
    sbar.exec(
      "omniwmctl query workspaces --focused --format json",
      function(ws_list)
        if type(ws_list) ~= "table" then return end

        local new_name = nil
        for _, ws in ipairs(ws_list) do
          if ws["is-focused"] == true then
            new_name = ws["raw-name"] or ws["display-name"]
            break
          end
        end

        if not new_name or new_name == focused_ws then return end

        -- Surgically flip highlight: old → off, new → on
        if focused_ws then render_highlight(focused_ws, false) end
        focused_ws = new_name
        render_highlight(focused_ws, true)
      end
    )
  end)

-- ══════════════════════════════════════════════════════════════════
--  Event: omniwm_windows
--  Source: omniwmctl watch windows-changed
--  Cost: 1 query (all windows at once), then diff per workspace.
--  Only workspaces whose strip actually changed get a :set() call.
-- ══════════════════════════════════════════════════════════════════
sbar.add("event", "omniwm_windows")

sbar.add("item", "omniwm_windows_obs", { drawing = false, updates = true })
  :subscribe("omniwm_windows", function(_env)
    sbar.exec("omniwmctl query windows --format json", function(all_wins)
      if type(all_wins) ~= "table" then return end

      -- Group windows by workspace
      local by_ws = {}
      for _, win in ipairs(all_wins) do
        local ws = win.workspace or ""
        if ws ~= "" then
          if not by_ws[ws] then by_ws[ws] = {} end
          table.insert(by_ws[ws], win)
        end
      end

      -- Diff each known workspace and patch only what changed
      local workspace_set_changed = false

      for ws_name in pairs(ws_state) do
        if not by_ws[ws_name] then
          -- Workspace has zero windows now; clear strip
          if ws_state[ws_name].strip ~= "" then
            render_strip(ws_name, "", false)
          end
        end
      end

      for ws_name, wins in pairs(by_ws) do
        if not ws_state[ws_name] then
          -- New workspace appeared → rebuild everything
          workspace_set_changed = true
        else
          local strip, has = build_strip(wins)
          if strip ~= ws_state[ws_name].strip then
            render_strip(ws_name, strip, has)
          end
        end
      end

      -- Check for removed workspaces too
      for ws_name in pairs(ws_state) do
        if not by_ws[ws_name] and not ws_state[ws_name] then
          workspace_set_changed = true
        end
      end

      -- Only do a full bootstrap when the workspace set itself changed
      if workspace_set_changed then
        bootstrap()
      end
    end)
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

-- ══════════════════════════════════════════════════════════════════
--  Boot
-- ══════════════════════════════════════════════════════════════════
bootstrap()
