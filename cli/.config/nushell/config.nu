# ~/.config/nu/config.nu
#
# ✅ Configuración modular de Nushell (v0.112+)
# Basado en mejores prácticas: https://www.nushell.sh/book/configuration.html
#
# Esta es la única entrada. Todo lo demás se carga desde subdirectorios.

# ────────────────────────────────────────────────
# 🌐 VARIABLES DE ENTORNO (Best Practice: aquí, no en env.nu)
# ────────────────────────────────────────────────

mkdir ~/.cache/carapace

### Carapace config
# https://carapace-sh.github.io/carapace-bin/setup/environment.html#carapace_lenient
$env.CARAPACE_LENIENT = "1"
$env.CARAPACE_BRIDGES = 'zsh,bash' # optional
$env.CARAPACE_CACHE = $"($nu.home-dir)/.cache/carapace"
# $env.CARAPACE_LOG = $"($env.HOME)/.cache/carapace.log"

mkdir ~/.config/nushell/integrations/carapace
#carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
carapace _carapace nushell | save --force ~/.config/nushell/integrations/carapace/carapace-init.nu

# Variables para el entorno nix
#nix-env.nu

# PATH: Añadir Homebrew y binarios locales sin duplicados
$env.PATH = ($env.PATH | split row (char esep)) ++ [
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  ($nu.home-dir | path join ".local/bin")
  "/Applications/Ghostty.app/Contents/MacOS"
] | uniq

# Variables específica^s
$env.STARSHIP_CONFIG = ($nu.home-dir | path join ".config/starship/starship.toml")
$env.GHOSTTY_CONFIG = ($nu.home-dir | path join ".config/ghostty/config")
$env._ZO_ECHO = 1

# Nix-related (opcional)
$env.NIX_PROFILES = "/nix/var/nix/profiles/default /run/current-system/sw"
$env.NIX_PATH = "darwin-config=$HOME/.nix-darwin darwin=flake:nix-darwin"

# LS_COLORS (si usas bat, ls con colores)
#$env.LS_COLORS = (fetch https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/LS_COLORS | str from)

# ────────────────────────────────────────────────
# ⚙️ CONFIGURACIÓN DE NUSHELL (`$env.config`)
# ────────────────────────────────────────────────

# Editor
$env.config.buffer_editor = "nvim"

# Modo vi
$env.config.edit_mode = "vi"

# Historial en SQLite
$env.config.history.file_format = "sqlite"

# Protocolo Kitty (mejor soporte de teclas)
# A keyboard enhancement protocol supported by the Kitty Terminal. Additional keybindings are
# available when using this protocol in a supported terminal. For example, without this protocol,
# Ctrl+I is interpreted as the Tab Key. With this protocol, Ctrl+I and Tab can be mapped separately.
$env.config.use_kitty_protocol = true

# Completados
# algorithm (string): Either "prefix" or "fuzzy"
$env.config.completions.algorithm = "fuzzy"

# Prompt minimalista
$env.config.show_banner = "short"

# Definimos los keybindings PRIMERO.
# Usamos empty list para asegurar que la variable existe.
$env.config.keybindings = []

# ────────────────────────────────────────────────
# 🔌 INTEGRACIONES EXTERNAS (autoload)
# ────────────────────────────────────────────────
# Carga primero los módulos funcionales que definen comandos y hooks
source ~/.config/nushell/integrations/zoxide.nu
source ~/.config/nushell/integrations/direnv.nu
source ~/.config/nushell/integrations/broot_shell.nu
source ~/.config/nushell/integrations/aichat_shell.nu
# Luego los que afectan el prompt o historial
source ~/.config/nushell/integrations/starship.nu
# Finalmente los que afectan completado externo
source ~/.config/nushell/integrations/carapace/carapace-init.nu

# Completados adicionales
# # Completadores para comandos externos
source ~/.config/nushell/completions/zoxide-cmp.nu
# Completadores para funciones internas (cd, cdi)
source ~/.config/nushell/completions/zoxide-complete.nu

# ────────────────────────────────────────────────
# ⌨️ KEYBINDINGS PERSONALIZADOS
# ────────────────────────────────────────────────
# Usamos ++ para NO borrar los bindings de las integraciones
$env.config.keybindings = ($env.config.keybindings ++ [
  {
    name: delete_one_word_backward
    modifier: control
    keycode: backspace
    mode: [emacs, vi_insert]
    event: { edit: backspaceword }
  }
])

# ────────────────────────────────────────────────
# 📦 FUNCIONES PERSONALIZADAS
# ────────────────────────────────────────────────
source ~/.config/nushell/functions/extras.nu

# ────────────────────────────────────────────────
# 🧩 ALIASES GLOBALES
# ────────────────────────────────────────────────
alias pipreset = do {jq '.vivaldi.pip_placement.left = 0 | .vivaldi.pip_placement.top = 0' $"($env.HOME)/Library/Application Support/Vivaldi/Default/Preferences"
  | save --force $"($env.HOME)/Library/Application Support/Vivaldi/Default/Preferences"}


# ─── 🧩 ALIASES: SISTEMA ─────────────────────────────
# alias la =  ls -la | select name type mode user group size modified | update modified {format date "%Y-%m-%d %H:%M:%S"}
alias la = do { ls -la | select name type mode user group size modified | update modified {format date "%Y-%m-%d %H:%M:%S"} }
# Lista archivos y directorios en formato árbol con detalles
alias lt = eza --tree --level=2 --long --icons --git
alias bcp0 = brew cleanup --prune=0
alias ngc = nix-collect-garbage -d
alias sgc = sudo nix-collect-garbage -d
alias dlg = darwin-rebuild --list-generations
alias yu = ya pkg upgrade
alias zsh-nuoff = do { NO_NU=1 zsh }
alias zs = zsh -l -i
alias fs = fish -l
# alias zsh-nuoff = with-env { NO_NU: "1" } { run-external "zsh" "-i" }
# Fuzzy finder de ventanas (Aerospace)
alias ff = do {
  aerospace list-windows --all \
    | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'
}
# ─── 🧩 ALIASES: DESARROLLO ──────────────────────────
alias j = just -f ~/.config/nix-darwin/Justfile -d ~/.config/nix-darwin/
alias cat = bat
alias v = nvim
alias vn = do { NVIM_APPNAME=nvim-dev bob run nightly }
alias urldecode = python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'
alias urlencode = python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'
alias devpod = zsh -ci "open -n /Applications/DevPod.app"
alias k = kubectl
alias trivy = docker run --rm -v trivy-cache:/root/.cache/ -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest
# Abrir tmux limpio
alias tmux-nu = do { tmux kill-server | complete; tmux }
# Alias para fzf + nvim
alias fzn = do {fzf --preview '''bat --style=numbers --color=always {}''' | xargs -n1 nvim}

# ─── 🧩 ALIASES: RED/SSH ─────────────────────────────
alias sshp = ssh -o ProxyJump=sabaext
alias sshtp = env TERM=xterm-256color ssh -o ProxyJump=sabaext
alias ssht = env TERM=xterm-256color ssh

# ─── 🧩 ALIASES: GIT ─────────────────────────────────
alias gp = git push origin main

# Definir función en vez de alias ya que da error con carapace en autocompletado
# al usar def --wrapped, Nushell hace algo muy inteligente "bajo el capó": 
# como el comando que se está llamando dentro (^git) es un comando externo conocido, 
# Nushell le pasa esa información a Carapace automáticamente y las flags pasan directo a git
def --wrapped dots [...args] {
    ^git --git-dir $"($env.HOME)/.my-dotfiles" --work-tree $env.HOME ...$args
}

# ────────────────────────────────────────────────
# 🚀 ATUIN (DEBE IR AL FINAL)
# ────────────────────────────────────────────────
# Al ponerlo al final, Atuin detecta tus keybindings y
# añade el suyo de Ctrl+R sin ser sobreescrito.
source ~/.config/nushell/integrations/atuin-init.nu

# scripts for unzip
use scripts/extractor.nu extract


