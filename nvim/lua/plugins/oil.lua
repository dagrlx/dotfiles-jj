return {
	"stevearc/oil.nvim",
	-- Optional dependencies
	dependencies = {
		{ "echasnovski/mini.icons", opts = {} }, -- Use mini.icons for file icons
		-- Alternatively, you can use nvim-web-devicons if preferred:
		-- { "nvim-tree/nvim-web-devicons" },
	},
	lazy = false, -- Lazy loading is not recommended for Oil
	config = function()
		require("oil").setup({
			default_file_explorer = true, -- Use Oil as the default file explorer
			columns = {
				"icon", -- Show file icons
				-- Uncomment the following lines to enable additional columns:
				-- "permissions",
				-- "size",
				-- "mtime",
			},
			keymaps = {
				["<C-h>"] = false, -- Disable default mapping
				["<C-c>"] = false, -- Prevent <C-c> from closing Oil (since it's often used as an escape key)
				["<M-h>"] = "actions.select_split", -- Open file in a split
				["q"] = "actions.close", -- Close Oil with 'q'
			},
			delete_to_trash = true, -- Move files to trash instead of deleting them permanently
			skip_confirm_for_simple_edits = false, -- Require confirmation for simple edits
			view_options = {
				show_hidden = true, -- Show hidden files by default
			},
			float = {
				padding = 2, -- Padding around the floating window
				max_width = 90, -- Maximum width of the floating window (can be an integer or a percentage like 0.4)
				max_height = 30, -- Maximum height of the floating window
				border = "rounded", -- Border style for the floating window
				win_options = {
					winblend = 0, -- No transparency for the floating window
				},
				preview_split = "auto", -- Split direction for previews: "auto", "left", "right", "above", "below"
				override = function(conf)
					return conf -- Customize the layout by overriding the default configuration
				end,
			},
		})

		-- Keybindings
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" }) -- Open Oil in the current directory
		vim.keymap.set("n", "<leader>-", require("oil").toggle_float) -- Open Oil in a floating window

		-- Autocommands
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil", -- Trigger on Oil file type
			callback = function()
				vim.opt_local.cursorline = true -- Enable cursorline in Oil buffers
			end,
		})
	end,
}
