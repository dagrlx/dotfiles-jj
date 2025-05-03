-- ~/.config/nvim/lua/plugins/nvim-treesitter.lua

return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	-- event = "VeryLazy",
	dependencies = {
		"windwp/nvim-ts-autotag",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},

	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"lua",
				"luadoc",
				"javascript",
				"json",
				"python",
				"html",
				"css",
				"csv",
				"dockerfile",
				"dot",
				"git_config",
				"gitignore",
				"markdown",
				"markdown_inline",
				"nix",
				"passwd",
				"php",
				"query",
				"sql",
				"ssh_config",
				"tmux",
				"toml",
				"vim",
				"vimdoc",
				"yaml",
				"rust",
				"regex",
			},

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,

			highlight = {
				enable = true,
				use_languagetree = true,
			},
			-- enable indentation
			indent = { enable = true },

			autotag = {
				enable = true, -- enable auto close tag html/xml
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			modules = {},
			ignore_install = {},
		})
	end,
}
