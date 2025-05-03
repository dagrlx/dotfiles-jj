-- ~/.config/nvim/lua/plugins/oil.lua

return {
	"stevearc/oil.nvim",
	opts = {
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-M-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
			["<C-,>"] = {
				"actions.select",
				opts = { horizontal = true },
				desc = "Open the entry in a horizontal split",
			},
			["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
			["<C-0>"] = "actions.preview",
			["<C-c>"] = "actions.close",
			["<C-l>"] = "actions.refresh",
			["-"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
			["gs"] = "actions.change_sort",
			["gx"] = "actions.open_external",
			["g."] = "actions.toggle_hidden",
			["g\\"] = "actions.toggle_trash",
		},
		use_default_keymaps = false,
		columns = {
			"icon",
			-- "permissions",
			-- "size",
			-- "mtime",
		},
		view_options = {
			show_hidden = true,
		},

		float = {
			-- Padding around the floating window
			padding = 2,
			max_width = 0,
			max_height = 0,
			border = "rounded",
			win_options = {
				winblend = 0,
			},
			-- This is the config that will be passed to nvim_open_win.
			-- Change values here to customize the layout
			override = function(conf)
				-- Personaliza la posición de la ventana flotante
				conf.relative = "editor"
				conf.anchor = "NW" -- Esquina superior izquierda como punto de anclaje (NW,NE,SW,SE)
				conf.row = 15 -- Ajusta el valor según la posición vertical deseada
				conf.col = 150 -- Ajusta el valor según la posición horizontal deseada
				conf.width = 80 -- Ancho de la ventana flotante
				conf.height = 20 -- Altura de la ventana flotante
				return conf
			end,
		},
	},
	-- Optional dependencies
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
