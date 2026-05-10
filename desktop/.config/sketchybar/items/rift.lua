local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Comandos para Rift
local QUERY_DISPLAYS = "rift-cli query displays"
local QUERY_WORKSPACES = "rift-cli query workspaces --space-id %d"
local FOCUS_WORKSPACE = "rift-cli execute workspace switch %d"

local spaces = {}
local icon_cache = {}
local displays_info = {}

-- Función para obtener el ícono de una aplicación
local function getIconForApp(appName)
    if not appName then return app_icons["Default"] end
    return icon_cache[appName] or app_icons[appName] or app_icons["Default"]
end

-- Función para actualizar información de displays
local function updateDisplaysInfo(callback)
    sbar.exec(QUERY_DISPLAYS, function(rift_displays)
        if not rift_displays or type(rift_displays) ~= "table" or #rift_displays == 0 then
            if callback then callback(false) end
            return
        end

        displays_info = {}
        for i, display in ipairs(rift_displays) do
            -- Validar que el display tenga los datos necesarios
            if display.uuid and display.space and display.screen_id and display.name then
                displays_info[i] = {
                    uuid = display.uuid,
                    space_id = display.space,
                    screen_id = display.screen_id,
                    name = display.name,
                    is_active = display.is_active_context or false
                }
            end
        end

        if #displays_info == 0 then
            if callback then callback(false) end
            return
        end

        if callback then callback(true) end
    end)
end

-- Función para actualizar los íconos de un workspace
local function updateSpaceIcons(spaceId, workspaceData)
    local icon_strip = ""
    local shouldDraw = false

    if workspaceData.windows and #workspaceData.windows > 0 then
        for _, window in ipairs(workspaceData.windows) do
            local bundleId = window.app_name
            if bundleId and bundleId ~= "" then
                icon_strip = icon_strip .. " " .. getIconForApp(bundleId)
                shouldDraw = true
            end
        end
    end

    if spaces[spaceId] then
        spaces[spaceId].item:set({
            label = { string = icon_strip, drawing = shouldDraw },
        })
    end
end

-- Función para crear un ítem de workspace para un display específico
local function createWorkspaceItem(display_index, space_id, workspaceData)
    -- Validación defensiva
    if not display_index or not space_id or not workspaceData or
        not workspaceData.name or not workspaceData.index then
        return nil
    end

    -- ID único: display_index.space_id.workspace_name
    local spaceId = string.format("d%d_s%d_ws%s", display_index, space_id, workspaceData.name)

    -- El parámetro 'display' asigna este item al monitor específico
    -- Funciona dinámicamente para cualquier número de displays (1, 2, 3, 4+)
    local space_item = sbar.add("item", spaceId, {
        position = "left",
        display = display_index,  -- Asignar al display específico
        drawing = spaces_visible, -- Respetar estado de visibilidad
        icon = {
            font = { family = settings.font.numbers },
            string = workspaceData.name,
            padding_left = 12,
            padding_right = 12,
            color = colors.white,
            highlight_color = colors.yellow,
        },
        label = {
            padding_right = 14,
            padding_left = 0,
            color = colors.grey,
            highlight_color = colors.yellow,
            font = "sketchybar-app-font:Regular:12.0",
            y_offset = -1,
        },
        padding_left = 2,
        padding_right = 2,
        background = {
            color = colors.bg1,
            border_width = 1,
            height = 26,
            border_color = colors.grey,
            corner_radius = 9,
        },
        click_script = FOCUS_WORKSPACE:format(workspaceData.index),
    })

    local space_bracket = sbar.add("bracket", { spaceId }, {
        drawing = spaces_visible, -- Respetar estado de visibilidad
        background = {
            color = colors.transparent,
            border_color = colors.transparent,
            height = 26,
            border_width = 1,
            corner_radius = 9,
        },
    })

    -- Click handler mejorado con feedback visual
    space_item:subscribe("mouse.clicked", function()
        sbar.exec(FOCUS_WORKSPACE:format(workspaceData.index), function(success)
            if not success then
                print("Warning: Failed to switch to workspace: " .. workspaceData.name)
            end
        end)
    end)

    -- Hover effect para mejor UX
    space_item:subscribe("mouse.entered", function()
        sbar.animate("tanh", 15, function()
            space_item:set({
                background = { color = colors.with_alpha(colors.grey, 0.3) }
            })
        end)
    end)

    space_item:subscribe("mouse.exited", function()
        sbar.animate("tanh", 15, function()
            space_item:set({
                background = { color = colors.bg1 }
            })
        end)
    end)

    return {
        item = space_item,
        bracket = space_bracket,
        name = workspaceData.name,
        index = workspaceData.index,
        id = spaceId,
        display_index = display_index,
        space_id = space_id,
    }
end

-- Función para actualizar la apariencia de un workspace
local function updateWorkspaceAppearance(spaceId, isActive, hasWindows)
    if not spaces[spaceId] then return end

    -- Color más prominente para workspaces con ventanas
    local iconColor = isActive and colors.yellow or (hasWindows and colors.white or colors.grey)
    local bgBorderColor = isActive and colors.dirty_white or
        (hasWindows and colors.with_alpha(colors.grey, 0.5) or colors.grey)

    spaces[spaceId].item:set({
        icon = {
            color = iconColor,
            highlight = isActive
        },
        label = { highlight = isActive },
    })

    spaces[spaceId].bracket:set({
        background = {
            border_color = bgBorderColor,
        },
    })
end

-- Función para actualizar workspaces de un display específico
local function updateWorkspacesForDisplay(display_index, space_id)
    -- Validación de parámetros
    if not display_index or not space_id then
        return
    end

    local command = QUERY_WORKSPACES:format(space_id)

    sbar.exec(command, function(workspacesOutput)
        if not workspacesOutput or type(workspacesOutput) ~= "table" then
            return
        end

        -- Ordenar workspaces por índice
        table.sort(workspacesOutput, function(a, b)
            -- Validar que ambos tengan índice antes de comparar
            if not a.index or not b.index then return false end
            return a.index < b.index
        end)

        local updatedSpaces = {}

        for _, workspaceData in ipairs(workspacesOutput) do
            -- VALIDACIÓN CRÍTICA: Verificar que los datos esenciales existan
            if not workspaceData.index or not workspaceData.name then
                goto continue
            end

            local spaceId = string.format("d%d_s%d_ws%s", display_index, space_id, workspaceData.name)

            -- Crear si no existe
            if not spaces[spaceId] then
                local new_space = createWorkspaceItem(display_index, space_id, workspaceData)
                -- Solo agregar si se creó exitosamente
                if new_space then
                    spaces[spaceId] = new_space
                else
                    goto continue
                end
            end

            -- Determinar si tiene ventanas
            local hasWindows = workspaceData.window_count and workspaceData.window_count > 0

            -- Actualizar apariencia basado en is_active y presencia de ventanas
            updateWorkspaceAppearance(spaceId, workspaceData.is_active, hasWindows)
            updateSpaceIcons(spaceId, workspaceData)

            updatedSpaces[spaceId] = true

            ::continue::
        end

        -- Eliminar workspaces obsoletos de este display
        for spaceId, space in pairs(spaces) do
            if space.display_index == display_index and not updatedSpaces[spaceId] then
                if space.item then sbar.remove(space.item) end
                if space.bracket then sbar.remove(space.bracket) end
                spaces[spaceId] = nil
            end
        end
    end)
end

-- Función para actualizar todos los displays
local function updateAllDisplays()
    updateDisplaysInfo(function(success)
        if not success then
            return
        end

        -- Actualizar workspaces para cada display
        for display_index, display_info in ipairs(displays_info) do
            updateWorkspacesForDisplay(display_index, display_info.space_id)
        end
    end)
end

-- Función para eliminar un ítem de workspace
local function removeWorkspaceItem(spaceId)
    if spaces[spaceId] then
        if spaces[spaceId].item then
            sbar.remove(spaces[spaceId].item)
        end
        if spaces[spaceId].bracket then
            sbar.remove(spaces[spaceId].bracket)
        end
        spaces[spaceId] = nil
    end
end

-- Estado para controlar visibilidad de workspaces
local spaces_visible = true

-- Función para mostrar/ocultar todos los workspaces
local function setWorkspacesVisibility(visible)
    for spaceId, space in pairs(spaces) do
        if space.item then
            space.item:set({ drawing = visible })
        end
        if space.bracket then
            space.bracket:set({ drawing = visible })
        end
    end
    spaces_visible = visible
end

-- Configuración inicial
print("Initializing Rift workspaces...")
updateAllDisplays()

-- Observador para cambios de workspace
local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true,
})

space_window_observer:subscribe({ "rift_workspace_changed", "rift_windows_changed" }, function()
    updateAllDisplays()
end)

-- Observador para cambios de space
space_window_observer:subscribe("space_change", function()
    updateAllDisplays()
end)

space_window_observer:subscribe("display_change", function()
    updateAllDisplays()
end)

-- Timer de respaldo para actualizaciones periódicas (reducido para mejor performance)
local backup_timer = sbar.add("item", {
    drawing = false,
    updates = true,
    update_freq = 10, -- Reducido de 5 a 10 segundos para mejor performance
})

backup_timer:subscribe("routine", function()
    updateAllDisplays()
end)

backup_timer:subscribe("system_woke", function()
    updateAllDisplays()
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

    -- Toggle visibilidad de workspaces
    setWorkspacesVisibility(not currently_on)
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
