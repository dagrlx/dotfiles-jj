-- ~/.config/nvim/lua/plugins/undotree.lua

return {
	"mbbill/undotree",

	vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>"),
}
