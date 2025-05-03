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
		local icon = icons.brew.empty
		local color = colors.green
		local label = "0"
		local drawing = "off"

		if tonumber(brew_outdated) > 0 then
			icon = icons.brew.full
			label = brew_outdated
			color = GetThresholdColor(brew_outdated)
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

-- Detecta si se ejecuto manualmente algunos de los comando y actualiza el widget
sbar.exec(

	[[

pgrep -lf "brew (upgrade|update|outdated)" | grep -q "brew" && sketchybar --trigger brew_update

]],

	function()
		sbar.trigger("brew_update")
	end
)
