return {
	"stevearc/conform.nvim",
	event = { "BufWritePre", "BufNewFile" },
	cmd = { "ConformInfo" },
	keys = {
		{
			-- Customize or remove this keymap to your liking
			"<leader>mp",
			function()
				require("conform").format({ async = true })
			end,
			mode = "",
			desc = "Format buffer",
		},
	},
	-- This will provide type hinting with LuaLS
	---@module "conform"
	---@type conform.setupOpts
	opts = {
		-- Define your formatters
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			yaml = { "yamlfix" },
			markdown = { "prettier" },
			toml = { "taplo" },
			sh = { "shfmt" },
			sql = { "sqlfluff" },
			bash = { "beautysh" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
			rust = { "rustfmt" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
		},
		-- Set default options
		default_format_opts = {
			lsp_format = "fallback",
		},
		-- Set up format-on-save
		format_on_save = {
			async = false,
			timeout_ms = 800,
		},

		-- options = {
		-- 	stylua = {
		-- 		args = {
		-- 			"--search-parent-directories", -- Buscar configuraciones en directorios superiores
		-- 			"--config", -- Pasar opciones de configuración directamente
		-- 			"indent_type=Spaces", -- Tipo de indentación
		-- 			"indent_width=4", -- Ancho de la indentación
		-- 			"column_width=120", -- Ancho máximo de columna
		-- 			"array_layout=Compact", -- Mantener tablas compactas
		-- 		},
		-- 	},
		-- },

		-- Customize formatters
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2" },
			},
		},
	},
	init = function()
		-- If you want the formatexpr, here is the place to set it
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
