return {
	"echasnovski/mini.nvim",
	version = false,
	-- dependencies = {
	-- 	"JoosepAlviste/nvim-ts-context-commentstring",
	-- },
	config = function()
		-- require("ts_context_commentstring").setup({
		-- 	enable_autocmd = false,
		-- })
		--
		-- require("mini.comment").setup({
		-- 	options = {
		-- 		custom_commentstring = function()
		-- 			if vim.bo.filetype == "nu" then
		-- 				return "# %s"
		-- 			end
		-- 			-- Usa el valor por defecto si no es un archivo Nushell
		-- 			return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
		-- 		end,
		-- 	},
		-- })

		require("mini.files").setup({
			windows = {
				preview = false,
			},
		})
		vim.keymap.set("n", "<leader>me", function()
			require("mini.files").open()
		end, { desc = "Explorador de archivos" })

		require("mini.pairs").setup()
		require("mini.surround").setup()
		require("mini.tabline").setup()
		-- require("mini.icons").setup()
	end,
}
