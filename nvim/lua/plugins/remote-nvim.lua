-- ~/.config/nvim/lua/plugins/remote-nvim.lua
--
return {
	"amitds1997/remote-nvim.nvim",
	version = "*", -- This keeps it pinned to semantic releases
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim", -- For standard functions
		"MunifTanjim/nui.nvim", -- To build the plugin UI
		-- "rcarriga/nvim-notify",
		-- This would be an optional dependency eventually
		"nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
	},
	config = true, -- This calls the default setup(); make sure to call it

	offline_mode = {
		enabled = true,
		no_github = false,
	},

	opts = {
		-- Abrir neovim remoto en pestaña nueva
		client_callback = function(port, workspace_config)
			-- Launch a new wezterm tab with ccustom title when launching Neovim client
			local cmd = ("wezterm cli set-tab-title --pane-id $(wezterm cli spawn nvim --server localhost:%s --remote-ui) %s"):format(
				port,
				("'Remote: %s'"):format(workspace_config.host)
			)
			-- Launch a new tmux window in the current session named 'Remote: <host>'
			if os.getenv("TMUX") ~= nil then
				cmd = ("tmux new-window -t $(tmux display-message -p '#S') -n 'SSH: %s' 'nvim --server localhost:%s --remote-ui'"):format(
					workspace_config.host,
					port
				)
			end
			if vim.env.TERM == "xterm-kitty" then
				cmd = ("kitty -e nvim --server localhost:%s --remote-ui"):format(port)
			end
			vim.fn.jobstart(cmd, {
				detach = true,
				on_exit = function(job_id, exit_code, event_type)
					-- This function will be called when the job exits
					print("Client", job_id, "exited with code", exit_code, "Event type:", event_type)
				end,
			})
		end,
	},
}
