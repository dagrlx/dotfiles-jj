-- ~/.config/nvim/lua/plugins/fzf-preview.lua

return {
	{
		"junegunn/fzf",
		run = function()
			vim.fn("fzf#install")
		end,
	},
	-- "junegunn/fzf.vim",
	"ibhagwan/fzf-lua", -- si estás usando fzf-lua
	"yuki-ycino/fzf-preview.vim",
	config = function()
		require("fzf-preview").setup({
			-- tu configuración aquí
		})
	end,
}
