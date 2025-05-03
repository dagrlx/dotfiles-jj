-- ~/.config/nvim/lua/plugins/bufferline.lua

return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
	enabled = true,
	opts = {
		options = {
			mode = "tabs",
			separator_style = "slant",
			--show_buffer_close_icons = false,  -- Oculta los íconos de cierre en cada buffer
			--show_close_icon = false,          -- Similar a la opción anterior, pero esta se refiere al ícono de cierre global para la barra de buffers
		},
	},
}
