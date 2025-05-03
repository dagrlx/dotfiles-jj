{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autocd = true;
    #autosuggestion.highlight = "fg=#808080,bg=none,bold,underline";
    autosuggestion.highlight = "fg=#f8f8f2,bg=#272822,bold";
    #autosuggestion.highlight = "fg=#c79267,bg=#282a36,bold,italic";
    syntaxHighlighting.enable = true; # Habilita el resaltado de sintaxis
    syntaxHighlighting.highlighters =
      [ "brackets" "pattern" "regexp" "cursor" "root" ];

    # Añadimos los patrones para abbr
    syntaxHighlighting.patterns = { "abbr *" = "fg=blue,bold"; };

    enableCompletion = true;
    #completionInit = "autoload -U compinit && compinit"; # Si se habilita este #deshabilita la caracteristicas de zsh-autocompletion
    autosuggestion.enable = true; # Habilita las sugerencias de autocompletado
    autosuggestion.strategy = [ "history" "completion" ];

    historySubstringSearch.enable = true; # Enable history substring search.
    sessionVariables = {
      HOSTNAME = "${builtins.getEnv "hostname"}"; # export HOSTNAME=$(hostname)
    };

    #initExtra = builtins.readFile ./zshrc

    # Commands that should be added to top of {file}.zshrc.
    # initExtraFirst = ''
    #   source $HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
    # '';

    initContent = ''

      # fixing delete key
      # https://superuser.com/questions/997593/why-does-zsh-insert-a-when-i-press-the-delete-key/1078653#1078653
      bindkey "^[[3~" delete-char

      bindkey '\C-z' undo

      #ABBR_DEFAULT_BINDINGS=0
      #bindkey "^ " abbr-expand-and-insert

      export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
      if [ -e '/nix/var/nix/profiles/default/etc/profi:WEZTERM_PANEle.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      eval "$(/opt/homebrew/bin/brew shellenv)"

      # Cargar funciones
      source ~/.config/nix-darwin/home/zsh_func

      # Agregar pkgx al PATH y cargar su configuración
      #source <(pkgx --shellcode)

      # Integracion de thefuck
      eval $(thefuck --alias)

      #export HOSTNAME=$(hostname)

      export STARSHIP_CONFIG=~/.config/starship/starship.toml
      eval "$(starship init zsh)"

      export XDG_CONFIG_HOME="/Users/dgarciar/.config"

      export SHELL=${pkgs.zsh}/bin/zsh

      export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
      zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
      source <(carapace _carapace)

      # Abbreviations variables
      export ABBR_GET_AVAILABLE_ABBREVIATION=1
      export ABBR_LOG_AVAILABLE_ABBREVIATION=1
      export ABBR_SET_EXPANSION_CURSOR=1

      # Load zsh-autosuggestions-abbreviations-strategy (Hombrew)
      source /opt/homebrew/share/zsh-autosuggestions-abbreviations-strategy/zsh-autosuggestions-abbreviations-strategy.zsh
      export ZSH_AUTOSUGGEST_STRATEGY=( abbreviations $ZSH_AUTOSUGGEST_STRATEGY )

      # Ghostty integration
      if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
          source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
      fi

      #source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

    '';

    zsh-abbr = {
      enable = true;
      abbreviations = {
        ufd = "darwin-rebuild switch --flake ~/.dotfiles/nix-darwin/ --verbose";
        ufn = "nix flake update --flake ~/.dotfiles/nix-darwin --verbose";
        ff =
          "aerospace list-windows --all | fzf --bind 'enter:execute(bash -c \"aerospace focus --window-id {1}\")+abort'";
        flushdns =
          "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
        allow_app =
          "codesign --sign - --force --deep @$ && xattr -d com.apple.quarantine @$"; # Para de-quarantine un app de MacOS
        open_fzn =
          "nvim $(fzf -m --preview='bat --style=numbers --color=always {}')";
      };
    };

    shellAliases = {
      rustscan =
      "docker run -it --rm --name rustscan --platform linux/amd64 rustscan/rustscan";
      "..." = "cd ../..";
      #ufd = "darwin-rebuild switch --flake ~/.dotfiles/nix-darwin/";
      #ufn = "nix flake update --flake ~/.dotfiles/nix-darwin";
      # Operates only for the current user
      # https://nixos.wiki/wiki/Storage_optimization#cite_note-4
      ngc = "nix-collect-garbage -d";
      # You can remove all but the current generation with
      # Or all generations older than a specific period (e.g. 30 days)
      # sudo nix-collect-garbage --delete-older-than 30d      
      sgc = "sudo nix-collect-garbage -d";
      dlg = "darwin-rebuild --list-generations";
      bcp0 = "brew cleanup --prune=0";
      brew-up ="brew update && brew upgrade && brew upgrade --cask --greedy"; 
      #flushdns = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
      #allow_app = "codesign --sign - --force --deep @$ && xattr -d com.apple.quarantine @$"; # Para de-quarantine un app de MacOS
      n = "nano -clS";
      cat = "bat";

      # Chezmoi y git
      chcd = "chezmoi cd";
      chra = "chezmoi re-add";
      chd = "chezmoi destroy";
      gp = "git push origin main";

      fzn =
        "fzf --preview 'bat --style=numbers --color=always {}' | xargs -n1 nvim";
      skn = ''
        sk --preview 'bat --style=numbers --color=always {}' | xargs -n1
              nvim'';
      sshtp = "TERM=xterm-256color ssh -o ProxyJump=sabaext";
      sshp = "ssh -o ProxyJump=sabaext";
      ssht = "TERM=xterm-256color ssh";
      c = "clear";

      urldecode =
        "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode =
        "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";

      #ff = "aerospace list-windows --all | fzf --bind 'enter:execute(bash -c \"aerospace focus --window-id {1}\")+abort'";

    };

    history = {
      size = 10000;
      ignoreDups = true; # Ignora duplicados
      #ignoreAllDups = true; # NO almacenar duplicados ** Investigar porque indica que opcion no existe para Macos
      ignoreSpace =
        true; # Elimina del historial los comandos que empiecen con un espacio
      extended = true; # Guarda el timestamp
      share = true; # Comparte el historial de comando entre sesiones
      expireDuplicatesFirst = true; # elimina los duplicados primero.
    };

    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [
    #     "git" "sudo" "tmux" "docker" "kubectl" "direnv" "brew" "minikube" "fzf" "aliases" "vscode"];
    #   theme = "strug"; #robbyrussell
    #   #theme = "robbyrussell";
    # };

    #    initExtra = "eval \"\$(zoxide init zsh)\"";

  };
}

