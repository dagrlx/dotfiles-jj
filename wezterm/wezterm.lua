local os = require("os")
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

--local cmd_sender = wezterm.plugin.require("https://github.com/aureolebigben/wezterm-cmd-sender")

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

resurrect.periodic_save()

-- Save only 5000 lines per pane
resurrect.set_max_nlines(5000)
--resurrect.change_state_save_dir("/Users/dgarciar/.local/share/wezterm/sessions/")

local function get_last_folder_segment(path)
	if type(path) ~= "string" then
		return ""
	end
	local segments = {}
	for segment in string.gmatch(path, "[^/\\]+") do
		table.insert(segments, segment)
	end
	return segments[#segments] or ""
end

-- Función para obtener el directorio de trabajo actual
local function get_current_working_dir(tab)
	local current_dir = tab.active_pane.current_working_dir
	if current_dir then
		current_dir = tostring(current_dir)
	----wezterm.log_info("Directorio actual: " .. current_dir)
	else
		current_dir = ""
	end
	return get_last_folder_segment(current_dir)
	--return current_dir  -- Devuelve la ruta completa del directorio
end

-- Icons for different processes
local process_icons = {
	["docker"] = wezterm.nerdfonts.linux_docker,
	["docker-compose"] = wezterm.nerdfonts.linux_docker,
	["psql"] = wezterm.nerdfonts.dev_postgresql,
	["kubectl"] = wezterm.nerdfonts.linux_docker,
	["stern"] = wezterm.nerdfonts.linux_docker,
	["nvim"] = wezterm.nerdfonts.custom_vim,
	["make"] = wezterm.nerdfonts.seti_makefile,
	["vim"] = wezterm.nerdfonts.dev_vim,
	["go"] = wezterm.nerdfonts.seti_go,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
	["bash"] = wezterm.nerdfonts.cod_terminal_bash,
	["btm"] = wezterm.nerdfonts.mdi_chart_donut_variant,
	["htop"] = wezterm.nerdfonts.md_chart_bar,
	["cargo"] = wezterm.nerdfonts.dev_rust,
	["sudo"] = wezterm.nerdfonts.fa_hashtag,
	["lazydocker"] = wezterm.nerdfonts.linux_docker,
	["git"] = wezterm.nerdfonts.dev_git,
	["lua"] = wezterm.nerdfonts.seti_lua,
	["wget"] = wezterm.nerdfonts.mdi_arrow_down_box,
	["curl"] = wezterm.nerdfonts.mdi_flattr,
	["gh"] = wezterm.nerdfonts.dev_github_badge,
	["ruby"] = wezterm.nerdfonts.cod_ruby,
	["pwsh"] = wezterm.nerdfonts.seti_powershell,
	["node"] = wezterm.nerdfonts.dev_nodejs_small,
	["dotnet"] = wezterm.nerdfonts.md_language_csharp,
}

-- Función para obtener el proceso en ejecución y su ícono
local default_icon = wezterm.nerdfonts.dev_terminal -- Ícono predeterminado para procesos no listados

local function get_process(tab)
	local process_name = tab.active_pane.foreground_process_name
	if process_name then
		process_name = string.match(process_name, "([^/\\]+)$")
	else
		process_name = "unknown"
	end
	local icon = process_icons[process_name] or default_icon
	return { icon = icon, name = process_name }
end

-- Configuración de WezTerm, this table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Ensures that a zsh session is always started within tmux if available, or just a zsh session if it is not
-- config.default_prog = {
-- 	"/bin/zsh",
-- 	"--login",
-- 	"-c",
-- 	[[
-- 	   if command -v tmux >/dev/null 2>&1; then
-- 	     tmux attach || tmux new;
-- 	   else
-- 	     exec zsh;
-- 	   fi
-- 	   ]],
-- }
--
-- config.default_prog = {
-- 	"/bin/zsh",
-- 	"--login",
-- 	"-c",
-- 	[[
--   if command -v tmux >/dev/null 2>&1; then
--     if [ -z "$TMUX" ]; then
--       echo "Do you want to use tmux? (y/n)"
--       read use_tmux
--       if [ "$use_tmux" = "y" ]; then
--         sessions=$(tmux ls | awk -F: '{print $1}')
--         if [ -n "$sessions" ]; then
--           echo "Available sessions:"
--           echo "$sessions"
--           echo "Enter session name to attach or press Enter to start a new session:"
--           read session_name
--           if [ -z "$session_name" ]; then
--             tmux new-session
--           else
--             tmux attach-session -t "$session_name" || tmux new-session -s "$session_name"
--           fi
--         else
--           tmux new-session
--         fi
--       else
--         exec zsh
--       fi
--     fi
--   else
--     exec zsh
--   fi
-- ]],
-- }

-- config.default_prog = {
-- 	"/bin/zsh",
-- 	"--login",
-- 	"-c",
-- 	[[
--   if command -v sesh >/dev/null 2>&1; then
--     while true; do
--       echo "¿Quieres usar tmux? (s/n)"
--       read use_tmux
--       case "$use_tmux" in
--         [Ss]*)
--           session=$( (echo "Nueva Sesión"; sesh list) | fzf --no-sort --ansi --border-label 'sesh' --prompt '⚡  ' --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find')
--           if [ "$session" = "Nueva Sesión" ]; then
--             echo "Introduce el nombre de la nueva sesión de tmux:"
--             read new_session
--             if [ -n "$new_session" ]; then
--               tmux new-session -s "$new_session"
--               tmux attach-session -t "$new_session"
--             else
--               tmux new-session
--               tmux attach-session -t "$(tmux display-message -p '#S')"
--             fi
--           elif [ -n "$session" ]; then
--             sesh connect "$session"
--           else
--             echo "Opción no válida."
--           fi
--           break;;
--         [Nn]*)
--           exec zsh
--           break;;
--         *)
--           echo "Entrada inválida. Por favor, presiona 's' para usar tmux o 'n' para una sesión normal."
--           ;;
--       esac
--     done
--   else
--     exec zsh
--   fi
-- ]],
-- }

config.automatically_reload_config = true
--config.color_scheme = "Catppuccin Mocha"
config.color_scheme = "Tokyo Night"
--config.color_scheme = "Tokyo Night Moon"
config.default_cursor_style = "BlinkingBar"

-- Set visual bell and audio bell
config.audible_bell = "SystemBeep"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"Hack Nerd Font",
	"Symbols Nerd Font",
})

config.font_size = 14.0
config.underline_thickness = 1
config.underline_position = -2.0

-- Windows configurartion
config.window_background_opacity = 0.85
--config.text_background_opacity = 0.5
config.macos_window_background_blur = 20
config.window_close_confirmation = "AlwaysPrompt"
config.adjust_window_size_when_changing_font_size = false
-- Controla la apariencia, funcionalidad de los bordes de la ventana y se permite redimensionarla
-- Valores  que se puede usar (REIZE, NONE, TITLE, RESIZE|TITLE, FULL)
config.window_decorations = "RESIZE|TITLE"
config.window_padding = {
	top = 5,
	right = 5,
	bottom = 0,
	left = 5,
}

config.enable_scroll_bar = true
config.scrollback_lines = 5000
config.min_scroll_bar_height = "0.7cell"
config.colors = {
	-- El color del "thumb" de la barra de desplazamiento; la parte que representa el viewport actual
	scrollbar_thumb = "#ff9452",
}

config.max_fps = 120

--config.use_dead_keys = false
config.warn_about_missing_glyphs = true --Activa/Desactiva las advertencias sobre glifos faltantes.

-- Colocando left y right en true permite que al presionar optio+ñ genere la ~ (Solo para macOS)
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- Config tab
--config.pane_focus_follows_mouse = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.switch_to_last_active_tab_when_closing_tab = true
config.show_new_tab_button_in_tab_bar = true
config.status_update_interval = 1000
config.tab_max_width = 60
config.tab_bar_at_bottom = false

-- Integración del portapapeles entre WezTerm y el sistema operativo.
-- copiar (Ctrl+Shift+C) , pegar (Ctrl+Shift+V)
enable_clipboard_integration = true

config.default_workspace = "Personal"

-- Setup muxing by default
config.unix_domains = {
	{
		name = "unix",
	},
}

-- Función para formatear el título de la pestaña
wezterm.on("format-tab-title", function(tab)
	local has_unseen_output = false
	local is_zoomed = false
	for _, pane in ipairs(tab.panes) do
		if pane.has_unseen_output then
			has_unseen_output = true
		end
		if pane.is_zoomed then
			is_zoomed = true
		end
	end

	local cwd = get_current_working_dir(tab)
	local process = get_process(tab)
	local zoom_icon = is_zoomed and wezterm.nerdfonts.cod_zoom_in or ""
	local title = string.format(" %s %s %s ", process.icon, process.name, cwd, zoom_icon)

	local formatted_title = wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Text = title },
	})

	if has_unseen_output then
		return {
			{ Foreground = { Color = "#28719c" } },
			{ Text = formatted_title },
		}
	else
		return {
			{ Text = formatted_title },
		}
	end
end)

-- Actualización del estado de la ventana
wezterm.on("update-status", function(window, pane)
	local workspace_or_leader = window:active_workspace()
	if window:active_key_table() then
		workspace_or_leader = window:active_key_table()
	end
	if window:leader_is_active() then
		workspace_or_leader = "LEADER"
	end

	local cmd = get_last_folder_segment(pane:get_foreground_process_name())
	local time = wezterm.strftime("%H:%M")
	local hostname = " " .. wezterm.hostname() .. " "

	window:set_right_status(wezterm.format({
		{ Text = wezterm.nerdfonts.oct_table .. " " .. workspace_or_leader },
		{ Text = " | " },
		{ Foreground = { Color = "FFB86C" } },
		{ Text = wezterm.nerdfonts.oct_command_palette .. " " .. cmd },
		"ResetAttributes",
		{ Text = " | " },
		{ Text = wezterm.nerdfonts.oct_person .. " " .. hostname },
		{ Text = " | " },
		{ Text = wezterm.nerdfonts.md_clock .. " " .. time },
		{ Text = " | " },
	}))
end)

config.inactive_pane_hsb = {
	saturation = 0.4,
	brightness = 0.5,
}

--wezterm.log_info("Configuración antes de aplicar cmd_sender:", config)

-- Custom key bindings

config.leader = { key = "Space", mods = "SHIFT", timeout_milliseconds = 3000 }
config.keys = {
	{ key = "C", mods = "LEADER", action = act.ActivateCopyMode },

	-- Copy mode
	{ key = "+", mods = "LEADER", action = act.ActivateCopyMode },

	{
		key = "w",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.save_state(resurrect.workspace_state.get_workspace_state())
		end),
	},
	-- {
	-- 	key = "W",
	-- 	mods = "ALT",
	-- 	action = resurrect.window_state.save_window_action(),
	-- },
	-- {
	-- 	key = "T",
	-- 	mods = "ALT",
	-- 	action = resurrect.tab_state.save_tab_action(),
	-- },
	{
		key = "S",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			local state = resurrect.workspace_state.get_workspace_state()
			resurrect.save_state(state)
			resurrect.window_state.save_window_action()
		end),
	},

	{
		key = "L",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = string.match(id, "(.+)%..+$") -- remove file extention
				local opts = {
					--	window = win:mux_window(),
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end)
		end),
	},

	{
		-- Delete a saved session using a fuzzy finder
		key = "d",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_load(win, pane, function(id)
				resurrect.delete_state(id)
			end, {
				title = "Delete State",
				description = "Select session to delete and press Enter = accept, Esc = cancel, / = filter",
				fuzzy_description = "Search session to delete: ",
				is_fuzzy = true,
			})
		end),
	},
	-- -- Vertical split
	-- {
	-- 	-- '¡'
	-- 	key = "¡",
	-- 	mods = "LEADER",
	-- 	action = act.SplitPane({
	-- 		direction = "Right",
	-- 		size = { Percent = 50 },
	-- 	}),
	-- },
	-- -- Horizontal split
	-- {
	-- 	-- -
	-- 	key = "-",
	-- 	mods = "LEADER",
	-- 	action = act.SplitPane({
	-- 		direction = "Down",
	-- 		size = { Percent = 50 },
	-- 	}),
	-- },
	-- Close/kill active pane
	{
		key = "x",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	-- Swap active pane with another one
	{
		key = "+",
		mods = "LEADER|ALT",
		action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }),
	},
	-- Zoom current pane (toggle)
	{
		key = "z",
		mods = "LEADER",
		action = act.TogglePaneZoomState,
	},
	{
		key = "f",
		mods = "ALT",
		action = act.TogglePaneZoomState,
	},
	-- Move to next/previous pane
	{
		key = ".",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Prev"),
	},
	{
		key = "o",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Next"),
	},

	-- Pane Keybindings (Sin wezterm.vim)
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "¡", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- LEADER + (h,j,k,l) to move between panes
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "s", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

	-- Tab Keybindings
	-- Create a tab (alternative to Ctrl-Shift-Tab)
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	-- Move to next/previous TAB
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	-- Show tab navigator; similar to listing panes in tmux
	{ key = "t", mods = "LEADER", action = act.ShowTabNavigator },
	{ key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },
	-- Close tab
	{ key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

	{ -- Move pane to new tab
		key = "M",
		mods = "CTRL | SHIFT",
		action = wezterm.action_callback(function(win, pane)
			local tab, window = pane:move_to_new_tab()
		end),
	},

	-- Move pane to new window
	{
		key = "N",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local tab, window = pane:move_to_new_window()
		end),
	},

	-- Rename current tab; analagous to command in tmux
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Workspace (These are roughly equivalent to tmux sessions.)
	-- ----------------------------------------------------------------
	-- Attach to muxer
	{
		key = "a",
		mods = "LEADER",
		action = act.AttachDomain("unix"),
	},

	-- Detach from muxer
	{
		key = "d",
		mods = "LEADER",
		action = act.DetachDomain({ DomainName = "unix" }),
	},

	-- Show list of workspaces
	{
		key = "w",
		mods = "LEADER",
		action = act.ShowLauncherArgs({ flags = "FUZZY|TABS|DOMAINS|WORKSPACES" }),
	},

	-- Rename current session; analagous to command in tmux
	{
		key = "W",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					mux.rename_workspace(window:mux_window():get_workspace(), line)
					-- window:perform_action(
					-- 	act.SwitchToWorkspace({
					-- 		name = line,
					-- 	}),
					-- 	pane
					-- )
				end
			end),
		}),
	},
}

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	move_tab = {
		{ key = "h", action = act.MoveTabRelative(-1) },
		{ key = "j", action = act.MoveTabRelative(-1) },
		{ key = "k", action = act.MoveTabRelative(1) },
		{ key = "l", action = act.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

--require("events")

return config

-- Ideas tomadas de:
-- https://github.com/danielcopper/dotfiles/blob/arch/.config/wezterm/wezterm.lua
-- https://mwop.net/blog/2024-07-04-how-i-use-wezterm.html
