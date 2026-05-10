local wezterm = require("wezterm")
local nf = wezterm.nerdfonts

return {
	["yazi"] = {
		Text = nf.md_duck,
	},
	["docker"] = {
		Text = nf.linux_docker,
	},
	["docker-compose"] = {
		Text = nf.linux_docker,
	},
	["tmux"] = {
		Text = nf.cod_terminal_tmux,
	},
	["kubectl"] = {
		Text = nf.linux_docker,
	},
	["nvim"] = {
		Text = "",
		--Text = nf.custom_vim,
	},
	["vim"] = {
		Text = nf.custom_vim, --nf.dev_vim,
	},
	["node"] = {
		Text = nf.md_hexagon,
	},
	["zsh"] = {
		Text = nf.oct_terminal,
		--Text = nf.md_lambda,
		--Text = nf.dev_terminal_badge,
		--Text = nf.mdi_apple_keyboard_command,
	},
	["bash"] = {
		Text = nf.cod_terminal_bash,
	},
	["btop"] = {
		Text = nf.md_chart_donut_variant,
	},
	["htop"] = {
		Text = nf.md_chart_bar,
	},
	["cargo"] = {
		Text = nf.dev_rust,
	},
	["rust"] = {
		Text = nf.dev_rust,
	},
	["go"] = {
		Text = nf.md_language_go,
	},
	["lazydocker"] = {
		Text = nf.linux_docker,
	},
	["git"] = {
		Text = nf.dev_git,
	},
	["lua"] = {
		Text = nf.seti_lua,
	},
	["wget"] = {
		--Text = nf.md_arrow_down_box,
		Text = nf.oct_download,
	},
	["curl"] = {
		Text = nf.md_flattr,
	},
	["gh"] = {
		Text = nf.dev_github_badge,
	},
	["ssh"] = {
		Text = nf.cod_terminal_linux,
		--Text = nf.fa_terminal,
		--Text = nf.md_ssh,
	},
	
}
