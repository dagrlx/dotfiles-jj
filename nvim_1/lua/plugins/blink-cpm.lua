return {
	{
		"saghen/blink.cmp",
		dependencies = {
			"rafamadriz/friendly-snippets",
			{ "saghen/blink.compat", lazy = true, version = false },
		},

		version = "v0.*",

		---@module 'blink.cmp'
		---@type blink.cmp.Config

		opts = {
			-- https://cmp.saghen.dev/configuration/keymap
			keymap = { preset = "enter" },

			-- https://cmp.saghen.dev/configuration/appearance.html
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},

			-- https://cmp.saghen.dev/configuration/sources.html
			-- sources = {
			-- 	default = { 'lsp', 'path', 'luasnip', 'buffer' },
			-- },

			sources = {
				-- https://cmp.saghen.dev/recipes.html#dynamically-picking-providers-by-treesitter-node-filetype
				default = function(ctx)
					local success, node = pcall(vim.treesitter.get_node)
					if vim.bo.filetype == "lua" then
						return { "lsp", "path" }
					elseif
						success
						and node
						and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type())
					then
						return { "buffer" }
					else
						return { "lsp", "path", "snippets", "buffer", "obsidian", "obsidian_new", "obsidian_tags" }
					end
				end,

				providers = {
					lsp = {
						min_keyword_length = 2, -- Number of characters to trigger provider
						score_offset = 0, -- Boost/penalize the score of the items
					},
					path = {
						min_keyword_length = 0,
					},
					snippets = {
						min_keyword_length = 2,
					},
					buffer = {
						min_keyword_length = 3,
						max_items = 5,
					},

					--https://github.com/rbmarliere/dotfiles/commit/edae7c4933300faf024b6cf6585085351840bba1
					obsidian = {
						name = "obsidian",
						module = "blink.compat.source",
					},
					obsidian_new = {
						name = "obsidian_new",
						module = "blink.compat.source",
					},
					obsidian_tags = {
						name = "obsidian_tags",
						module = "blink.compat.source",
					},
				},

				-- Disable cmdline completions
				-- cmdline = {},
			},

			-- https://cmp.saghen.dev/configuration/signature.html
			signature = {
				enabled = true,
				window = {
					border = "rounded",
				},
			},

			-- https://cmp.saghen.dev/configuration/completion.htm
			completion = {

				-- 'prefix' will fuzzy match on the text before the cursor
				-- 'full' will fuzzy match on the text before *and* after the cursor
				-- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'

				keyword = { range = "full" },

				-- Disable auto brackets
				-- NOTE: some LSPs may add auto brackets themselves anyway
				accept = { auto_brackets = { enabled = false } },

				-- https://cmp.saghen.dev/configuration/completion.html#menu
				menu = {
					-- Don't automatically show the completion menu
					-- auto_show = false,

					border = "rounded",

					-- nvim-cmp style menu
					draw = {
						--columns = { { "label", "label_description", gap = 2 }, { "kind_icon", "kind", gap = 2 } },
						treesitter = { "lsp" },
					},
				},

				-- https://cmp.saghen.dev/configuration/reference#completion-ghost-text
				-- Display a preview of the selected item on the current line
				ghost_text = { enabled = true },

				-- https://cmp.saghen.dev/configuration/completion.html#documentation
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					update_delay_ms = 50,
					treesitter_highlighting = true,
					window = { border = "rounded" },
				},

				-- https://cmp.saghen.dev/configuration/completion.html#list
				-- Don't select by default, auto insert on selection
				-- list = { selection = { preselect = false, auto_insert = true } },

				list = {
					selection = {
						preselect = function(ctx)
							-- return ctx.mode ~= "cmdline"
							return ctx.mode ~= "cmdline" and not require("blink.cmp").snippet_active({ direction = 1 })
						end,
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
