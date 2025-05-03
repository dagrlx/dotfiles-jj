-- ~/.config/nvim/lua/plugins/auto-pairs.lua

return {
	"windwp/nvim-autopairs",
	event = { "InsertEnter" },
	dependencies = {
		"saghen/blink.cmp",
	},
	-- use treesitter to check for a pai
	config = function()
		-- import nvim-autopairs
		local autopairs = require("nvim-autopairs")
		local Rule = require("nvim-autopairs.rule")

		-- configure autopairs
		autopairs.setup({
			check_ts = true, -- enable treesitter
			ts_config = {
				lua = { "string" }, -- don't add pairs in lua string treesitter nodes
				javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
				java = false, -- don't check treesitter on java
			},
		})

		local ts_conds = require("nvim-autopairs.ts-conds")

		-- press % => %% only while inside a comment or string
		autopairs.add_rules({
			Rule("%", "%", "lua"):with_pair(ts_conds.is_ts_node({ "string", "comment" })),
			Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({ "function" })),
		})
	end,
}
