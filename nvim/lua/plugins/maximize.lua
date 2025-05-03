-- ~/.config/nvim/lua/plugins/maximize.lua

return {
	"declancm/maximize.nvim",
	config = function()
		require("maximize").setup()

		-- Mapeo para hacer toggle de la maximización
		vim.api.nvim_set_keymap(
			"n",
			"<leader>m",
			':lua require("maximize").toggle()<CR>',
			{ noremap = true, silent = true }
		)
	end,
}
