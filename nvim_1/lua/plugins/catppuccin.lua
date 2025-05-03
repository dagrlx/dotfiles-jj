-- ~/.config/nvim/lua/plugins/catppuccin.lua

return {
	"catppuccin/nvim",
	as = "catppuccin",
	config = function()
		require("catppuccin").setup({
			flavour = "mocha", -- O cualquier otro sabor que prefieras
			integrations = {
				nvimtree = true,
				telescope = true,
				-- Agrega más integraciones si lo necesitas
			},
		})
		vim.cmd("colorscheme catppuccin")
	end,
}
