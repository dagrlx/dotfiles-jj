local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Comandos para obtener información sobre monitores y workspaces
local LIST_MONITORS = "aerospace list-monitors | awk '{print $1}'"
local LIST_WORKSPACES = "aerospace list-workspaces --monitor %s"
local LIST_APPS = "aerospace list-windows --workspace %s | awk -F'|' '{gsub(/^ *| *$/, \"\", $2); print $2}'"
local LIST_CURRENT = "aerospace list-workspaces --focused"

-- =====================================================
-- CONFIGURACIÓN GLOBAL Y ESTILOS (Asumiendo colores/iconos están definidos arriba)
-- =====================================================

local spaces = {} -- { spaceId = { item = ..., bracket = ... } }
local workspaceToMonitorMap = {} -- { workspaceName = monitorId }

-- Función auxiliar para crear un ítem de Workspace (simplificada)
local function createWorkspaceItem(spaceId, workspaceName, monitorId)
	return {
		item = sbar.add("item", {
			drawing = false,
			label = {
				padding_right = 14,
				padding_left = 0,
				color = colors.grey,
				highlight_color = colors.yellow,
				font = "sketchybar-app-font:Regular:12.0",
				y_offset = -1,
			},
			background = {
				color = colors.bg1,
				border_width = 1,
				height = 26,
				border_color = colors.grey,
				corner_radius = 9,
			},
			click_script = "aerospace workspace --fail-if-noop " .. workspaceName,
			display = monitorId,
		}),
		bracket = sbar.add("bracket", { spaceId }, {
			background = {
				color = colors.transparent,
				border_color = colors.transparent,
				height = 26,
				border_width = 1,
				corner_radius = 9,
			},
		}),
	}
end

-- Función para actualizar la apariencia de un workspace (Optimización: solo actualiza lo necesario)
local function updateWorkspaceAppearance(spaceId, isSelected)
	local spaceData = spaces[spaceId]
	if not spaceData then
		return
	end

	-- Actualizar el ítem principal
	spaceData.item:set({
		icon = { highlight = isSelected },
		label = { highlight = isSelected },
	})
	-- Actualizar el bracket (solo si es necesario)
	spaceData.bracket:set({
		background = {
			border_color = isSelected and colors.dirty_white or colors.transparent,
		},
	})
end

-- Función para añadir o actualizar un ítem de workspace
local function addOrUpdateWorkspaceItem(workspaceName, monitorId, isSelected)
	local spaceId = "workspace_" .. workspaceName .. "_" .. monitorId
	if not spaces[spaceId] then
		spaces[spaceId] = createWorkspaceItem(spaceId, workspaceName, monitorId)
		-- Aquí se debería llamar a updateSpaceIcons si es necesario para el ícono
		workspaceToMonitorMap[workspaceName] = monitorId
	end
	updateWorkspaceAppearance(spaceId, isSelected)
end

-- Función para eliminar un ítem de workspace (Limpieza de memoria)
local function removeWorkspaceItem(spaceId)
	if spaces[spaceId] then
		sbar.remove(spaces[spaceId].item)
		sbar.remove(spaces[spaceId].bracket)
		spaces[spaceId] = nil
		-- Limpiar mapa de mapeo si es necesario
		local workspaceName = spaceId:match("workspace_(.-)_%d+")
		if workspaceName then
			workspaceToMonitorMap[workspaceName] = nil
		end
	end
end

-- Función para ejecutar comandos de manera segura
local function safeExec(command, callback)
	sbar.exec(command, function(output)
		if output then
			callback(output)
		else
			print("Error: Command failed - " .. command)
		end
	end)
end

-- Función principal para sincronizar todos los workspaces (Refactorizada)
local function updateAllWorkspaces()
	-- 1. Obtener monitores
	safeExec(LIST_MONITORS, function(monitorList)
		local currentSpaces = {} -- Para rastrear qué workspaces existen en esta ejecución

		for _, monitorId in ipairs(monitorList) do
			-- 2. Obtener workspaces para el monitor actual
			getWorkspacesForMonitor(monitorId, function(workspaces)
				local updatedInThisRun = {}
				for _, workspaceName in ipairs(workspaces) do
					local spaceId = "workspace_" .. workspaceName .. "_" .. monitorId
					local isSelected = (workspaceName == getFocusedWorkspace()) -- Necesitas obtener el foco aquí o pasarlo como argumento
					addOrUpdateWorkspaceItem(workspaceName, monitorId, isSelected)
					updatedInThisRun[spaceId] = true
				end

				-- 3. Limpieza: Eliminar workspaces que ya no existen en este monitor
				for spaceId in pairs(spaces) do
					if not updatedInThisRun[spaceId] and spaceId:match("_%d+$") == "_" .. monitorId then
						removeWorkspaceItem(spaceId)
					end
				end
			end)
		end
	end)
end

-- =====================================================
-- INICIALIZACIÓN Y OBSERVADORES (Mantenidos, pero mejorados en la lógica de llamada)
-- =====================================================
local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

space_window_observer:subscribe({ "aerospace_workspace_change", "front_app_switched" }, function()
	updateAllWorkspaces()
end)

-- Manejar el evento aerospace_monitor_change
sbar.add("item", {
	drawing = false,
	updates = true,
}):subscribe("aerospace_monitor_change", function(env)
	local focused_monitor = env.FOCUSED_MONITOR
	-- print("Monitor enfocado: " .. focused_monitor)
	-- Aquí puedes añadir lógica para actualizar la interfaz según el monitor
end)

-- Manejar el evento aerospace_focus_change
sbar.add("item", {
	drawing = false,
	updates = true,
}):subscribe("aerospace_focus_change", function()
	-- print("El foco ha cambiado")
	-- Aquí puedes añadir lógica para actualizar la interfaz según el foco
end)

-- Indicador para intercambiar menús y espacios
local spaces_indicator = sbar.add("item", {
	padding_left = -3,
	padding_right = 0,
	icon = {
		padding_left = 8,
		padding_right = 9,
		color = colors.grey,
		string = icons.switch.on,
	},
	label = {
		width = 0,
		padding_left = 0,
		padding_right = 8,
		string = "Spaces",
		color = colors.bg1,
	},
	background = {
		color = colors.with_alpha(colors.grey, 0.0),
		border_color = colors.with_alpha(colors.bg1, 0.0),
	},
})

local function toggleSpacesIndicator(currently_on)
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end

spaces_indicator:subscribe("swap_menus_and_spaces", function()
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	toggleSpacesIndicator(currently_on)
end)

local function animateSpacesIndicator(entered)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = entered and 1.0 or 0.0 },
				border_color = { alpha = entered and 0.5 or 0.0 },
			},
			icon = { color = entered and colors.bg1 or colors.grey },
			label = { width = entered and "dynamic" or 0 },
		})
	end)
end

spaces_indicator:subscribe("mouse.entered", function()
	animateSpacesIndicator(true)
end)
spaces_indicator:subscribe("mouse.exited", function()
	animateSpacesIndicator(false)
end)
spaces_indicator:subscribe("mouse.clicked", function()
	sbar.trigger("swap_menus_and_spaces")
end)
