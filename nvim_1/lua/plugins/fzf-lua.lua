-- ~/.config/nvim/lua/plugins/fzf-lua.lua

return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- calling `setup` is optional for customization
		require("fzf-lua").setup({
			files = {
				cmd = "fd --type f --hidden --follow --exclude .git",
			},
			previewers = {
				bat = {
					cmd = "bat",
					args = "--style=numbers,changes --color always",
				},
			},
		})
	end,
}
