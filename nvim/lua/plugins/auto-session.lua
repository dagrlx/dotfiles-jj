return {
	"rmagatti/auto-session",
	lazy = false,

	opts = {
		auto_restore = true, -- Enables/disables auto restoring session on start
		suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
		auto_restore_last_session = false, -- On startup, loads the last saved session if session for cwd does not exist

		-- log_level = 'debug',
	},

	keys = {
		{ "<leader>wh", "<cmd>SessionSearch<CR>", desc = "Session search" },
		{ "<leader>wr", "<cmd>SessionRestore<CR>", desc = "Restore session for cwd" },
		{ "<leader>ws", "<cmd>SessionSave<CR>", desc = "Save session" },
	},
}

-- Exit with :q and reenter Neovim with nvim .

-- When working in a project, you can now close everything with :qa and when you open Neovim again in this directory you can use <leader>wr to restore your workspace/session.
