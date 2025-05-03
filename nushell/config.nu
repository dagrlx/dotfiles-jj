# Nushell Config File

$env.XDG_CONFIG_HOME = ($nu.home-path | path join ".config")

# history in format sqlite
$env.config.history.file_format = "sqlite"

# Active mode vim
$env.config.edit_mode = "vi"

# Show only startup time  
$env.config.show_banner = "short"

# use_kitty_protocol (bool):
# A keyboard enhancement protocol supported by the Kitty Terminal. Additional keybindings are
# available when using this protocol in a supported terminal. For example, without this protocol,
# Ctrl+I is interpreted as the Tab Key. With this protocol, Ctrl+I and Tab can be mapped separately.
$env.config.use_kitty_protocol = true

$env.config.buffer_editor = "nvim"

# algorithm (string): Either "prefix" or "fuzzy"
$env.config.completions.algorithm = "prefix"

##################### ALIASES ##########################

# alias la =  ls -la | select name type mode user group size modified | update modified {format date "%Y-%m-%d %H:%M:%S"}
alias la = do { ls -la | select name type mode user group size modified | update modified {format date "%Y-%m-%d %H:%M:%S"} }

# Lista archivos y directorios en formato árbol con detalles
alias lt = eza --tree --level=2 --long --icons --git

alias cat = bat

# Limpieza de brew
alias bcp0 = brew cleanup --prune=0

# Actualizacion de nix
alias ufn = nix flake update --flake ~/.dotfiles/nix-darwin --verbose

# Actualizacion de nix-darwin
alias ufd = darwin-rebuild switch --flake ~/.dotfiles/nix-darwin/ --verbose

# Listado de generaciones Darwin (Rollback)
alias dlg = darwin-rebuild --list-generations

# Limpieza de nix
alias ngc = nix-collect-garbage -d
alias sgc = sudo nix-collect-garbage -d

# Proxy ssh sabaext
alias sshp = ssh -o ProxyJump=sabaext

# Proxy ssh saba xterm-256color 
alias sshtp = env TERM=xterm-256color ssh -o ProxyJump=sabaext

# Para equipos que no tienen xterm-ghostty
alias ssht  = env TERM=xterm-256color ssh

# Chezmoi y git
alias chcd = chezmoi cd
alias chra = chezmoi re-add
alias chd = chezmoi destroy
alias gp = git push origin main

# Mata el server si existe, y luego siempre ejecuta tmux
alias tmux-nu = do {tmux kill-server | complete; tmux}

# list applications in Aerospace for selection
alias ff = do {aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'}

# Busca archivos con fzf mostrando preview con bat y abre el seleccionado en nvim.
alias fzn = do {fzf --preview '''bat --style=numbers --color=always {}''' | xargs -n1 nvim
}

# Actualización plugin de Yazi
alias yu-nu = ya pack --upgrade

# Kubernete
alias k = kubectl

alias devpod = zsh -ci "open -n /Applications/DevPod.app"

# Expande alias o elementos en abbreviations presionando space o enter
# https://github.com/nushell/nushell/issues/5552#issuecomment-2113935091
let abbreviations = {
    "cd..": 'cd ..'
    sau: 'sudo apt update; sudo apt upgrade'
    bwu: 'brew update; brew upgrade; sketchybar --trigger brew_update'
}

$env.config.keybindings ++= [
    {
        name: abbr_menu
        modifier: none
        keycode: enter
        mode: [emacs, vi_normal, vi_insert]
        event: [
            { send: menu name: abbr_menu }
            { send: enter }
        ]
    }
    {
        name: abbr_menu
        modifier: none
        keycode: space
        mode: [emacs, vi_normal, vi_insert]
        event: [
            { send: menu name: abbr_menu }
            { edit: insertchar value: ' ' }
        ]
    }
]

$env.config.menus ++= [
    {
        name: abbr_menu
        only_buffer_difference: false
        marker: "👀 "
        type: {
            layout: columnar
            columns: 1
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            if $buffer in ["z", "zi"] {
                { value: $buffer }
            } else {
                let alias_match = (scope aliases | where name == $buffer)

                if ($alias_match | is-empty) {
                    let abbr_match = $abbreviations | columns | where $it == $buffer
                    if ($abbr_match | is-empty) {
                        { value: $buffer }
                    } else {
                        { value: ($abbreviations | get $abbr_match.0) }
                    }
                } else {
                    $alias_match | each { |it| 
                        let expansion = $it.expansion
                        if ($expansion | str starts-with 'do {') {
                            { value: ($expansion | str replace -r '^do\s*\{\s*(.*?)\s*\}$' '$1') }
                        } else {
                            { value: $expansion }
                        }
                    }
                }
            }
        }
    }
]

# Codificación y decodificación de URLs usando urllib.parse
alias urldecode = do { python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))' }
alias urlencode = do { python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))' }

##################################################################################################################


# Caparace autocompletation
#source ~/.cache/carapace/init.nu
source ~/.dotfiles/nushell/carapace/carapace.nu

# Config for use of atuin
source ~/.dotfiles/nushell/atuin-init.nu
source ~/.dotfiles/nushell/atuin-cmp.nu

# Cargar funciones complejas desde un archivo externo
source ~/.dotfiles/nushell/functions.nu

# Shell integration for aichat
source ~/.dotfiles/nushell/aichat_shell.nu

# autocompletation for aichat
source ~/.dotfiles/nushell/aichat_cmp.nu

# Broot file manager
source ~/.dotfiles/nushell/broot_shell.nu

########## Integración de zoxide ####################
source ~/.dotfiles/nushell/zoxide.nu
use ~/.dotfiles/nushell/zoxide-completions.nu *

# Completador para z
def "nu-complete zoxide path" [context: string] {
  let parts = $context | split row " " | skip 1
  {
    options: {
      sort: false,
      completion_algorithm: fuzzy,
      positional: true,
      case_sensitive: false,
    },
    completions: (
      zoxide query --list --exclude $env.PWD -- ...$parts
      | lines
      | each {|it| { value: $it description: "zoxide match" }}
    )
  }
}

# # Comando z con completador
def --env --wrapped z [...rest: string@"nu-complete zoxide path"] {
  __zoxide_z ...$rest
}

##########################################################


# scripts for unzip 
use scripts/extractor.nu extract

$env.NU_PLUGIN_PATH = [
    "/opt/homebrew/bin"
]

#source ~/.dotfiles/nushell/completation.nu

# Config starship
mkdir ($nu.default-config-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.default-config-dir | path join "vendor/autoload/starship.nu")

$env.STARSHIP_CONFIG = "/Users/dgarciar/.dotfiles/starship/starship.toml"

