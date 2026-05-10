-- Aerospace Workspace Indicator para SketchyBar
-- Versión estable con manejo de errores y optimizaciones

local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Configuración de comandos
local LIST_MONITORS = "aerospace list-monitors | awk '{print $1}'"
local LIST_WORKSPACES = "aerospace list-workspaces --monitor %s"
local LIST_APPS = "aerospace list-windows --workspace %s | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, \"\", $2); print $2}'"
local LIST_CURRENT = "aerospace list-workspaces --focused"

-- Estructuras de datos
local spaces = {}
local workspaceToMonitorMap = {}
local icon_cache = {}
local updateLock = false

-- Funciones auxiliares
local function trim(s)
	return s and s:gsub("^%s*(.-)%s*$", "%1") or ""
end

local function getIconForApp(appName)
	appName = trim(appName)
	if not appName then
		return app_icons["Default"]
	end

	if not icon_cache[appName] then
		icon_cache[appName] = app_icons[appName] or app_icons["Default"]
	end
	return icon_cache[appName]
end

-- Generador seguro de IDs
local function generateSpaceId(workspaceName, monitorId)
	return ("workspace_%s_%s"):format(workspaceName:gsub("[^%w%-]", "_"):gsub("_+", "_"), monitorId)
end

-- Ejecución segura de comandos
local function safeExec(command, callback)
	sbar.exec(command, function(output)
		if output and #output > 0 then
			callback(output)
		else
			print("Error: Command failed - " .. command)
		end
	end)
end

-- Obtener lista de monitores
local function getMonitors(callback)
	safeExec(LIST_MONITORS, function(output)
		local monitors = {}
		for monitor in output:gmatch("[^\r\n]+") do
			table.insert(monitors, trim(monitor))
		end
		callback(monitors)
	end)
end

-- Obtener espacio de trabajo enfocado
local function getFocusedWorkspace(callback)
	safeExec(LIST_CURRENT, function(output)
		local focused = trim(output:match("[^\r\n]+"))
		callback(focused)
	end)
end

-- Obtener espacios de trabajo por monitor
local function getWorkspacesForMonitor(monitorId, callback)
	safeExec(LIST_WORKSPACES:format(monitorId), function(output)
		local workspaces = {}
		for ws in output:gmatch("[^\r\n]+") do
			table.insert(workspaces, trim(ws))
		end
		table.sort(workspaces, function(a, b)
			return a:lower() < b:lower()
		end)
		callback(workspaces)
	end)
end

-- Creación de elementos
local function createWorkspaceItem(workspaceName, monitorId)
	local spaceId = generateSpaceId(workspaceName, monitorId)

	local space_item = sbar.add("item", spaceId, {
		icon = {
			font = { family = settings.font.numbers },
			string = workspaceName,
			padding = { left = 12, right = 12 },
			color = colors.white,
			highlight_color = colors.yellow,
		},
		label = {
			padding = { right = 14 },
			color = colors.grey,
			highlight_color = colors.yellow,
			font = "sketchybar-app-font:Regular:12.0",
			y_offset = -1,
		},
		background = {
			color = colors.bg1,
			border = { width = 1, color = colors.grey },
			corner_radius = 9,
			height = 26,
		},
		click_script = ("aerospace workspace --fail-if-noop '%s'"):format(workspaceName:gsub("'", "'\\''")),
		display = monitorId,
	})

	local space_bracket = sbar.add("bracket", { spaceId }, {
		background = {
			border = { width = 1 },
			corner_radius = 9,
			height = 26,
		},
	})

	space_item:subscribe("mouse.clicked", function()
		sbar.exec(
			("aerospace workspace --fail-if-noop '%s'"):format(workspaceName:gsub("'", "'\\''")),
			function(success)
				if not success then
					print("Error changing workspace: " .. workspaceName)
				end
			end
		)
	end)

	return {
		item = space_item,
		bracket = space_bracket,
		name = workspaceName,
		monitor = monitorId,
	}
end

-- Actualización de elementos
local function updateWorkspaceIcons(spaceId, workspaceName)
	sbar.exec(LIST_APPS:format(workspaceName), function(output)
		local icons = {}
		for app in output:gmatch("[^\r\n]+") do
			local appName = trim(app)
			if appName ~= "" then
				table.insert(icons, getIconForApp(appName))
			end
		end

		if spaces[spaceId] then
			spaces[spaceId].item:set({
				label = {
					string = #icons > 0 and table.concat(icons, " ") or "",
					drawing = #icons > 0,
				},
			})
		end
	end)
end

local function updateWorkspaceState(spaceId, isSelected)
	if not spaces[spaceId] then
		return
	end

	spaces[spaceId].item:set({
		icon = { highlight = isSelected },
		label = { highlight = isSelected },
	})

	spaces[spaceId].bracket:set({
		background = {
			border_color = isSelected and colors.dirty_white or colors.transparent,
		},
	})
end

-- Gestión de elementos
local function addOrUpdateWorkspace(workspaceName, monitorId, isSelected)
	local spaceId = generateSpaceId(workspaceName, monitorId)

	if not spaces[spaceId] then
		spaces[spaceId] = createWorkspaceItem(workspaceName, monitorId)
		workspaceToMonitorMap[workspaceName] = monitorId
	end

	updateWorkspaceState(spaceId, isSelected)
	updateWorkspaceIcons(spaceId, workspaceName)
end

local function removeWorkspace(spaceId)
	if spaces[spaceId] then
		if sbar.exists(spaces[spaceId].item) then
			sbar.remove(spaces[spaceId].item)
		end
		if sbar.exists(spaces[spaceId].bracket) then
			sbar.remove(spaces[spaceId].bracket)
		end

		local wsName = spaceId:match("^workspace_([^_]+)_.*")
		if wsName then
			workspaceToMonitorMap[wsName] = nil
		end
		spaces[spaceId] = nil
	end
end

-- Actualización principal
local function updateAllWorkspaces()
	if updateLock then
		return
	end
	updateLock = true

	getMonitors(function(monitors)
		getFocusedWorkspace(function(focused)
			local activeSpaces = {}

			for _, monitor in ipairs(monitors) do
				getWorkspacesForMonitor(monitor, function(workspaces)
					for _, ws in ipairs(workspaces) do
						local spaceId = generateSpaceId(ws, monitor)
						addOrUpdateWorkspace(ws, monitor, ws == focused)
						activeSpaces[spaceId] = true
					end

					-- Limpiar espacios obsoletos
					for spaceId in pairs(spaces) do
						if spaceId:match(("_%s$"):format(monitor)) and not activeSpaces[spaceId] then
							removeWorkspace(spaceId)
						end
					end
				end)
			end
		end)
	end)

	updateLock = false
end

-- Observadores
local observer = sbar.add("item", { updates = true, drawing = false })
observer:subscribe({ "aerospace_workspace_change", "front_app_switched" }, function()
	if not updateLock then
		sbar.timer.once(0.15, updateAllWorkspaces)
	end
end)

-- Indicador de espacios
local spacesIndicator = sbar.add("item", {
	icon = {
		string = icons.switch.on,
		color = colors.grey,
		padding = { left = 8, right = 9 },
	},
	label = {
		string = "Spaces",
		color = colors.bg1,
		width = 0,
	},
	background = {
		color = colors.with_alpha(colors.grey, 0.0),
		border_color = colors.with_alpha(colors.bg1, 0.0),
	},
})

local function toggleIndicator()
	local current = spacesIndicator:query().icon.value
	spacesIndicator:set({ icon = { string = current == icons.switch.on and icons.switch.off or icons.switch.on } })
end

local function animateIndicator(enter)
	sbar.animate("tanh", 30, function()
		spacesIndicator:set({
			background = {
				color = { alpha = enter and 1.0 or 0.0 },
				border_color = { alpha = enter and 0.5 or 0.0 },
			},
			icon = { color = enter and colors.bg1 or colors.grey },
			label = { width = enter and "dynamic" or 0 },
		})
	end)
end

spacesIndicator:subscribe("mouse.entered", function()
	animateIndicator(true)
end)
spacesIndicator:subscribe("mouse.exited", function()
	animateIndicator(false)
end)
spacesIndicator:subscribe("mouse.clicked", function()
	sbar.trigger("swap_menus_and_spaces")
end)
spacesIndicator:subscribe("swap_menus_and_spaces", toggleIndicator)

-- Inicialización
updateAllWorkspaces()
