local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local thresholds = {
	[3] = colors.yellow,
	[5] = colors.orange,
	[10] = colors.red,
}

local brew = sbar.add("item", "widgets.brew", {
	position = "right",
	drawing = "off",
	icon = {
		string = icons.brew.empty,
		color = colors.green,
		align = "left",
	},
	label = {
		string = "0",
		font = { family = settings.font.numbers },
	},
	updates = "on",
	update_freq = 60, -- Actualiza cada 60 segundos
})

-- Variable para almacenar el último conteo de paquetes desactualizados
local last_outdated_count = 0

-- Función para determinar el color según el umbral
local function GetThresholdColor(count)
	local thresholdKeys = {}
	for key in pairs(thresholds) do
		table.insert(thresholdKeys, key)
	end
	table.sort(thresholdKeys, function(a, b)
		return a > b
	end)
	for _, threshold in ipairs(thresholdKeys) do
		if tonumber(count) >= threshold then
			return thresholds[threshold]
		end
	end
	return colors.green
end

-- Función que ejecuta brew outdated y actualiza el widget
local function update_brew_status()
	sbar.exec("brew outdated | wc -l | tr -d ' '", function(brew_outdated)
		local count = tonumber(brew_outdated) or 0

		-- Solo actualiza el widget si el conteo ha cambiado
		if count ~= last_outdated_count then
			last_outdated_count = count

			local icon = icons.brew.empty
			local color = colors.green
			local label = "0"
			local drawing = "off"

			if count > 0 then
				icon = icons.brew.full
				label = tostring(count)
				color = GetThresholdColor(count)
				drawing = "on"
			end

			brew:set({
				icon = {
					string = icon,
					color = color,
				},
				drawing = drawing,
				label = { string = label },
			})
		end
	end)
end

-- Suscribir a eventos de actualización
brew:subscribe({ "routine", "brew_update" }, update_brew_status)

-- Agregar un bracket y padding como en el original
sbar.add("bracket", "widgets.brew.bracket", { brew.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.brew.padding", {
	position = "right",
	width = settings.group_paddings,
})

-- Verificar cambios en los paquetes desactualizados cada 5 segundos
sbar.add("timer", "widgets.brew.timer", {
	interval = 5, -- Verifica cada 5 segundos
	updates = "on",
	script = [[
        sketchybar --trigger brew_update
    ]],
})
