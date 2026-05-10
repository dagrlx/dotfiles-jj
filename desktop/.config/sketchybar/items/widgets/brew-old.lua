local icons = require("icons")
local settings = require("settings")
local colors = require("colors")

-- Crear el widget principal de brew
local brew = sbar.add("item", "widgets.brew", {
	position = "right",
	icon = {
		string = icons.brew.empty, -- Icono inicial (cuando no hay paquetes desactualizados)
		font = {
			family = settings.nerd_font, -- Asegúrate de que esta fuente esté configurada
			style = "Regular",
			size = 19.0,
		},
		color = colors.green, -- Color inicial del icono
	},
	label = {
		string = "0", -- Valor inicial
		color = colors.text, -- Color del texto
		font = {
			family = settings.font.numbers, -- Asegúrate de que esta fuente esté configurada
			size = 12.0,
		},
	},
	background = {
		color = colors.bg1, -- Fondo gris oscuro
		drawing = true, -- Asegúrate de que el fondo se dibuje
	},
	drawing = "on", -- Asegúrate de que el widget esté visible desde el inicio
	update_freq = 300, -- Actualiza cada 300 segundos (5 minutos)
	popup = {
		align = "right",
		height = 20,
	},
})

-- Crear un popup para mostrar los detalles de los paquetes desactualizados
local brew_details = sbar.add("item", "widgets.brew.details", {
	position = "popup." .. brew.name,
	click_script = "sketchybar --set widgets.brew popup.drawing=off",
	background = {
		color = colors.bg1, -- Color de fondo del popup
		corner_radius = 12,
		padding_left = 5,
		padding_right = 10,
	},
})

-- Variable para almacenar el último conteo de paquetes desactualizados
local last_outdated_count = 0

-- Función para limpiar el popup
local function clear_popup()
	local existing_packages = brew:query()
	if existing_packages.popup and next(existing_packages.popup.items) ~= nil then
		for _, item in pairs(existing_packages.popup.items) do
			sbar.remove(item)
		end
	end
end

-- Variable para controlar la limpieza del popup
local skip_cleanup = false

-- Manejar clics del mouse
brew:subscribe({ "mouse.clicked" }, function(info)
	if info.BUTTON == "left" then
		-- Alternar la visibilidad del popup
		sbar.exec("sketchybar --set widgets.brew popup.drawing=toggle")
	elseif info.BUTTON == "right" then
		-- Forzar una actualización
		sbar.trigger("brew_update")
	end
end)

-- Ocultar el popup cuando el mouse sale del widget
brew:subscribe({ "mouse.exited", "mouse.exited.global" }, function()
	brew:set({ popup = { drawing = false } })
end)

-- Mostrar el popup cuando el mouse entra en el widget
brew:subscribe({ "mouse.entered" }, function()
	brew:set({ popup = { drawing = true } })
end)

-- Limpiar el popup cuando se dispara el evento brew_cleanup
brew:subscribe({ "brew_cleanup" }, function()
	if not skip_cleanup then
		brew:set({ label = "0" })
		clear_popup()
	end
end)

-- Función para actualizar el widget
local function update_brew_widget()
	skip_cleanup = false

	-- Ejecutar brew update y brew outdated
	sbar.exec("brew update")
	sbar.exec("brew outdated", function(outdated)
		skip_cleanup = true

		-- Definir umbrales de color
		local thresholds = {
			{ count = 30, color = colors.red },
			{ count = 20, color = colors.orange },
			{ count = 10, color = colors.yellow },
			{ count = 1, color = colors.green },
			{ count = 0, color = colors.text },
		}

		-- Contar paquetes desactualizados
		local count = 0
		for _ in outdated:gmatch("\n") do
			count = count + 1
		end

		-- Actualizar el widget solo si el conteo ha cambiado
		if count ~= last_outdated_count then
			last_outdated_count = count

			-- Limpiar el popup
			clear_popup()

			-- Agregar paquetes desactualizados al popup
			for package in outdated:gmatch("[^\n]+") do
				sbar.add("item", "widgets.brew.package." .. package, {
					label = {
						string = tostring(package),
						align = "right",
						padding_right = 20,
						padding_left = 20,
					},
					icon = {
						string = tostring(package),
						drawing = false,
					},
					click_script = "sketchybar --set widgets.brew popup.drawing=off",
					position = "popup." .. brew.name,
				})
			end

			-- Cambiar el ícono y el color según el número de paquetes desactualizados
			local icon = (count > 0) and icons.brew.full or icons.brew.empty
			local color = colors.green

			for _, threshold in ipairs(thresholds) do
				if count >= threshold.count then
					color = threshold.color
					break
				end
			end

			brew:set({
				icon = {
					string = icon,
					color = color,
				},
				label = {
					string = tostring(count),
					color = colors.text, -- Asegúrate de que el texto sea visible
				},
				background = {
					color = colors.bg1, -- Fondo gris oscuro
					drawing = true,
				},
			})
		end
	end)
end

-- Actualizar el widget cuando se dispara el evento brew_update
brew:subscribe({ "routine", "forced", "brew_update" }, update_brew_widget)

-- Verificar periódicamente si hay cambios en los paquetes desactualizados
sbar.add("timer", "widgets.brew.timer", {
	interval = 5, -- Verifica cada 5 segundos
	updates = "on",
	script = [[
        sketchybar --trigger brew_update
    ]],
})

-- Disparar una limpieza inicial
sbar.trigger("brew_cleanup")
