# ================= ENVIRONMENT & PATH =================
# Variables de entorno globales
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx STARSHIP_CONFIG "$XDG_CONFIG_HOME/starship/starship.toml"
set -gx GHOSTTY_CONFIG "$HOME/.config/ghostty/config"
set -gx NH_DARWIN_FLAKE "$HOME/.config/nix-darwin"
set -gx CARAPACE_BRIDGES 'zsh,fish,bash'
set -gx _ZO_ECHO 1
set -gx _ZO_RESOLVE_SYMLINKS 1
set -gx NH_DARWIN_FLAKE "$HOME/.dotfiles-jj/nix-darwin/.config/nix-darwin"

# PATH moderno (fish_add_path evita duplicados automáticamente)
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
fish_add_path /run/current-system/sw/bin
fish_add_path "$HOME/.nix-profile/bin"
fish_add_path "$HOME/.lmstudio/bin"

# Homebrew (detecta shell y exporta set -gx automáticamente)
if command -q brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# Nix daemon (Bass para compatibilidad con script Bash)
if test -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    bass source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
end

# Límite de archivos abiertos
ulimit -n 4096

# ================= ALIASES & ABBREVIATIONS =================
# Abbreviations (se expanden al presionar espacio, solo interactivas)
abbr -a v nvim
# abbr -a dots 'git --git-dir=$HOME/.my-dotfiles --work-tree=$HOME'
# abbr -a gco "git checkout"

# Aliases (disponibles también en scripts/sesiones no interactivas)
alias dots='git --git-dir=$HOME/.my-dotfiles --work-tree=$HOME'
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
alias fzn="fzf --read0 --print0 --preview 'bat --style=numbers --color=always {}' | xargs -0 nvim"
alias skn="sk --read0 --print0 --preview 'bat --style=numbers --color=always {}' | xargs -n1 nvim"
alias sshtp="TERM=xterm-256color ssh -o ProxyJump=sabaext"
alias sshp="ssh -o ProxyJump=sabaext"
alias ssht="TERM=xterm-256color ssh"
alias c="clear"
alias urldecode="python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'"
alias urlencode="python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'"
alias vn="NVIM_APPNAME=nvim-dev bob run nightly"
alias yu="ya pkg upgrade"
alias baofirma='bao write -field=signed_key ssh/sign/admin-ssh public_key=@$HOME/.ssh/dagrlx_ed25519.pub > ~/.ssh/dagrlx_ed25519-cert.pub && echo "✅ Certificado renovado"'
alias fs='fish'
alias ns='nu'

# ================= INTERACTIVE SESSIONS ONLY =================
if status is-interactive
    # Inicialización de herramientas
    atuin init fish --disable-up-arrow | source
    starship init fish | source
    zoxide init fish --cmd cd | source
    direnv hook fish | source
    carapace _carapace | source

    # Autocompletado de jj (dinámico)
    COMPLETE=fish jj | source

 end

