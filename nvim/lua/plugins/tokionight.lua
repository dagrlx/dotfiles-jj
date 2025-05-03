return {
	{
		"folke/tokyonight.nvim",
		enabled = false,
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
		},
		config = function()
			vim.cmd("syntax on")
			vim.o.termguicolors = true -- True color (24bits) in terminal
			-- Aplicar el esquema de color después de cargar el plugin
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},
}
