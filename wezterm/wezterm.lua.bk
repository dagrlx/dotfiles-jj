local wezterm = require 'wezterm';
local Tab = require 'tab';
--local tab = require("tab")

local config = {}
-- Use config builder object if possible
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 150,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 150,
}
config.colors = {
	visual_bell = "#303030",
}

config.color_scheme = 'catppuccin-macchiato' --Tokyo Night' 
--config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font = wezterm.font_with_fallback({
  { family = "JetBrainsMono Nerd Font",       scale = 1.2, weight = "Medium", },
  { family = "FantasqueSansM Nerd Font", scale = 1.3, },
  { family = "Noto Sans", scale = 1.0 },
  { family = "BlexMono Nerd Font", scale = 1.0 },
    
})
config.font_size = 12.0
--#line_height= 1.2

config.colors = {
  -- El color del "thumb" de la barra de desplazamiento; la parte que representa el viewport actual
  scrollbar_thumb = '#ff9452', --#D3D3D3',
  -- Puedes cambiar los colores aquí según prefieras
}

-- Colocando left y right en true permite que al presionar optio+ñ genere la ~ 
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true


--Set window opacity
config.window_background_opacity = 0.9 -- personal recommended value
config.text_background_opacity = 0.5
macos_window_background_blur = 30

enable_clipboard_integration = true

--Activa la barra de desplazamiento
config.enable_scroll_bar = true


config.window_background_gradient = {
  -- Can be "Vertical" or "Horizontal".  Specifies the direction
  -- in which the color gradient varies.  The default is "Horizontal",
  -- with the gradient going from left-to-right.
  -- Linear and Radial gradients are also supported; see the other
  -- examples below
  orientation = 'Vertical',

  -- Specifies the set of colors that are interpolated in the gradient.
  -- Accepts CSS style color specs, from named colors, through rgb
  -- strings and more
  colors = {
    '#0f0c29',
    '#302b63',
    '#24243e',
  },

  -- Instead of specifying `colors`, you can use one of a number of
  -- predefined, preset gradients.
  -- A list of presets is shown in a section below.
  -- preset = "Warm",

  -- Specifies the interpolation style to be used.
  -- "Linear", "Basis" and "CatmullRom" as supported.
  -- The default is "Linear".
  interpolation = 'Linear',

  -- How the colors are blended in the gradient.
  -- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
  -- The default is "Rgb".
  blend = 'Rgb',

  -- To avoid vertical color banding for horizontal gradients, the
  -- gradient position is randomly shifted by up to the `noise` value
  -- for each pixel.
  -- Smaller values, or 0, will make bands more prominent.
  -- The default value is 64 which gives decent looking results
  -- on a retina macbook pro display.
  -- noise = 64,

  -- By default, the gradient smoothly transitions between the colors.
  -- You can adjust the sharpness by specifying the segment_size and
  -- segment_smoothness parameters.
  -- segment_size configures how many segments are present.
  -- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
  -- 1.0 is a soft edge.

  -- segment_size = 11,
  -- segment_smoothness = 0.0,
}


--Disable fancy tab style
--config.use_fancy_tab_bar = true

--Hide the tab bar if there is only one tab
--config.hide_tab_bar_if_only_one_tab = true

--Display Tab Navigator
local act = wezterm.action

--Para mitigar caso https://github.com/wez/wezterm/issues/2910
config.mouse_bindings = {
  { event = { Down = { streak = 1, button = 'Left' } }, mods = 'SHIFT', action = act.SelectTextAtMouseCursor('Cell') },
  { event = { Down = { streak = 2, button = 'Left' } }, mods = 'SHIFT', action = act.SelectTextAtMouseCursor('Word') },
  { event = { Down = { streak = 3, button = 'Left' } }, mods = 'SHIFT', action = act.SelectTextAtMouseCursor('Line') },
  -- Agrega otras asignaciones de acciones del mouse según tus preferencias
}

config.keys = {
  {
    key = 't',
    mods = 'CMD|SHIFT',
    action = act.ShowTabNavigator,
  },
  {
    key = 'R',
    mods = 'CMD|SHIFT',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, _, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  {
    key = ',',
    mods = 'CMD',
    action = act.SpawnCommandInNewTab {
      cwd = os.getenv('WEZTERM_CONFIG_DIR'),
      set_environment_variables = {
        TERM = 'screen-256color',
      },
      args = {
        '/etc/profiles/per-user/dgarciar/bin/nvim',
        os.getenv('WEZTERM_CONFIG_FILE'),
      },
    },
  },
  -- other keys
}

--Para diferenciar que pane esta activo
config.inactive_pane_hsb = {
  saturation = 0.2,
  brightness = 0.5,
}

-- and finally, return the configuration to wezter
if Tab and Tab.setup then
  Tab.setup(config)
else
  print("El módulo 'tab' no se ha cargado correctamente o la función 'setup' no existe")
end

return config

--Link de configuraciones
--https://ansidev.substack.com/p/wezterm-cheatsheet
--https://github.com/RauliL/wezterm-config/blob/master/wezterm.lua
--https://github.com/emretuna/.dotfiles/tree/main/wezterm/.config/wezterm
