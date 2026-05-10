typeset -U path PATH  # Elimina duplicados en PATH
# ========== PATH y entorno ==========
# Evita errores si Homebrew no está instalado
if command -v brew >/dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Primero Homebrew, luego Nix
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH"
##export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

export XDG_CONFIG_HOME="$HOME/.config"

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

export GHOSTTY_CONFIG="$HOME/.config/ghostty/config"

# Aumentar límite de archivos abiertos para Nix, fzf
ulimit -n 4096

# ========== Fix teclas ==========
bindkey "^[[3~" delete-char
bindkey '\C-z' undo

# ========== History ==========
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history
setopt hist_ignore_dups
setopt hist_expire_dups_first
setopt hist_ignore_space
setopt extended_history

# ========== Autosuggestions ==========
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#f8f8f2,bg=#272822,bold"

# ========== zsh-abbr ==========
source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh

# Abbreviations strategy
source /opt/homebrew/share/zsh-autosuggestions-abbreviations-strategy/zsh-autosuggestions-abbreviations-strategy.zsh
export ZSH_AUTOSUGGEST_STRATEGY=(abbreviations history completion)

# ========== Syntax Highlighting ==========
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern regexp cursor root)
ZSH_HIGHLIGHT_PATTERNS=('abbr *' 'fg=blue,bold')

# Regenerar el dump solo si cambia - Esto evita recargar completados innecesariamente
# Si no existe el dump, o si .zshrc fue modificado después del último dump, borra el caché viejo y genera uno nuevo.
setopt local_options no_nomatch  # Evita error si no hay archivos
if [[ ! -f ~/.zcompdump ]] || [[ ~/.zshrc -nt ~/.zcompdump ]]; then
  rm -f ~/.zcompdump*
fi

autoload -Uz compinit && compinit -d ~/.zcompdump
# zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
#zstyle ':completion:*' format $'\e[48;5;232m\e[1;37m %d \e[0m'
# Habilitar menú de selección en completado
zstyle ':completion:*' menu yes select search
zstyle ':completion:*' complete-options true

# ========== Funciones y extras ==========
[ -f "$XDG_CONFIG_HOME/nix-darwin/home/zsh_func" ] && source "$XDG_CONFIG_HOME/nix-darwin/home/zsh_func"
# ========== Carapace ==========
export CARAPACE_BRIDGES='zsh,fish,bash'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# --- Autocompletacion dinamica para jujutsu
source <(COMPLETE=zsh jj)

if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

## Variable para nh (Hay que revisar porque no se carga en el sistema)
export NH_DARWIN_FLAKE=/Users/dgarciar/.config/nix-darwin

# ========== Aliases ==========
alias rustscan="docker run -it --rm --name rustscan --platform linux/amd64 rustscan/rustscan"
alias ...="cd ../.."
alias ngc="nix-collect-garbage -d"
alias sgc="sudo nix-collect-garbage -d"
alias dlg="darwin-rebuild --list-generations"
alias bcp0="brew cleanup --prune=0"
alias brew-up="brew update && brew upgrade && brew upgrade --cask --greedy"
alias n="nano -clS"
alias cat="bat"
alias gp="git push origin main"
alias dots='git --git-dir=$HOME/.my-dotfiles --work-tree=$HOME'
alias fzn='fzf --read0 --print0 --preview "bat --style=numbers --color=always {}" | xargs -0 nvim'
alias skn="sk --read0 --print0 --preview 'bat --style=numbers --color=always {}' | xargs -n1 nvim"
alias sshtp="TERM=xterm-256color ssh -o ProxyJump=sabaext"
alias sshp="ssh -o ProxyJump=sabaext"
alias ssht="TERM=xterm-256color ssh"
alias c="clear"
alias urldecode="python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'"
alias urlencode="python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'"
alias v="nvim"
alias vn="NVIM_APPNAME=nvim-dev bob run nightly"
alias yu="ya pkg upgrade"
alias baofirma='bao write -field=signed_key ssh/sign/admin-ssh public_key=@$HOME/.ssh/dagrlx_ed25519.pub > ~/.ssh/dagrlx_ed25519-cert.pub && echo "✅ Certificado renovado"'

# ... (todo tu PATH, history, plugins, etc. se queda igual)

# ========== Alias para shells ==========
# Fish
if command -v fish > /dev/null 2>&1; then
    alias fs='fish'
    alias fish-shell='fish'
    echo "✅ Fish disponible. Usa 'fs' o 'fish-shell' para iniciarlo."
fi

# Nushell
if command -v nu > /dev/null 2>&1; then
    alias ns='nu'
    alias nushell='nu'
    echo "✅ Nushell disponible. Usa 'ns' o 'nushell' para iniciarlo."
fi

eval "$(zoxide init zsh --cmd cd)"

# ========== Activación de zsh-abbr ==========
eval "$(atuin init zsh --disable-up-arrow)"

# ========== Starship prompt ==========
eval "$(starship init zsh)"

eval "$(direnv hook zsh)"

# eval $(thefuck --alias)

# ========== Lanzar Nushell en sesiones interactivas ==========
# if [[ $- == *i* ]] && command -v nu >/dev/null; then
#   exec nu
# fi
#
# if [[ $- == *i* ]] && [[ -z "$NO_NU" ]] && command -v nu >/dev/null; then
#   exec nu
# fi

# if command -v nu > /dev/null 2>&1 && [ -z "$NU_ACTIVE" ]; then
#     export NU_ACTIVE=1
#     exec nu
# fi

# ========== Mensaje ==========
# Solo se muestgra si es sesión interactiva
# if [[ $- == *i* ]]; then
#   echo -e "\e[1;35mZsh cargado ☕\e[0m"
# fi

# if [[ -t 1 && $- == *i* ]]; then
#   echo -e "\e[1;35mZsh cargado ☕\e[0m"
# fi
#

# # Si es una terminal interactiva y fish está instalado, usa fish
# if command -v fish > /dev/null 2>&1; then
#     exec fish
# fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/dgarciar/.lmstudio/bin"
# End of LM Studio CLI section

