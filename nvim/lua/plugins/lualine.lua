-- Función para obtener el estado de Codeium
local function codeium_status()
	-- Llama a la función de Codeium usando la API de Neovim
	local status = vim.fn.trim(vim.api.nvim_call_function("codeium#GetStatusString", {}))

	-- Procesa el estado y retorna el icono correspondiente
	if status == "ON" then
		return "" -- Icono para Codeium activo
	elseif status == "OFF" then
		return "" -- Icono para Codeium inactivo
	elseif status == "*" then
		return "⌛" -- Icono para esperando respuesta
	elseif status == "0" then
		return "󰜺" -- Icono para sin sugerencias
	elseif string.match(status, "^%d+/%d+$") then
		return " (" .. status .. ")" -- Icono con las sugerencias actuales
	else
		return "" -- Estado desconocido
	end
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				--theme = "tokyonight",
				theme = "catppuccin",
				component_separators = { " ", " " },
				section_separators = { left = "", right = "" },
				-- component_separators = "|",
				-- section_separators = { "", "" },
			},
			sections = {
				lualine_b = {
					"branch",
					"diff",
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						sections = { "error", "warn", "info", "hint" },
						diagnostics_color = {
							error = "DiagnosticError",
							warn = "DiagnosticWarn",
							info = "DiagnosticInfo",
							hint = "DiagnosticHint",
						},
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
						colored = true,
						update_in_insert = false,
						always_visible = false,
					},
					{
						function()
							return vim.g.remote_neovim_host and ("Remote: %s"):format(vim.uv.os_gethostname()) or ""
						end,
						padding = { right = 1, left = 1 },
						separator = { left = "", right = "" },
					},
				},

				lualine_c = {
					{
						"filename",
						file_status = true,
						path = 0,
						shorting_target = 40,
						symbols = {
							modified = "󰐖 ", -- Text to show when the file is modified.
							readonly = " ", -- Text to show when the file is non-modifiable or readonly.
							unnamed = "[No Name]", -- Text to show for unnamed buffers.
							newfile = "[New]", -- Text to show for new created file before first writting
						},
					},
				},
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
					"python_env",
					{
						-- Componente personalizado para Codeium
						function()
							return codeium_status()
						end,
						color = { fg = "#ffffff" }, -- Color del texto (ajusta según tu tema)
					},
				},
			},
			tabline = {},
			extensions = {
				"quickfix",
				"oil",
				"fzf",
				"lazy",
				"mason",
			},
		})
	end,
}
