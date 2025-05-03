{ pkgs, ... }:

{
  home.packages = with pkgs; [
    #nixVersions.latest

    #nnn # terminal file manager

    #python3Full
    #unstable-nixpkgs.python311Packages.gssapi

    # archives
    zip
    xz
    unzip
    p7zip
    unar

    #Fonts
    #nerdfonts

    # utils
    mc
    ntfs3g
    fping
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor - Instalado con brew
    yq-go # yaml processer https://github.com/mikefarah/yq
    fzf # A command-line fuzzy finder
    fzf-zsh
    zsh-fzf-tab # Replace zsh's default completion selection menu with fzf
    #nix-index

    fd # para buscar archivos
    ffmpegthumbnailer # thumbnails de video necesario para yazi
    imagemagick # Yazi 0.3 now supports previewing fonts, SVGs, HEIC, and JPEG XL files
    procs # Moderno reemplazo de ps basado e Rust
    android-tools
    cheat
    coreutils-full
    curl
    duf
    du-dust
    has
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    mas # Mac App Store command-line interface
    nmap # A utility for network discovery and security auditing
    #httpie

    nano
    nanorc
    sshpass
    sshfs
    tealdeer # A very fast implementation of tldr in Rust
    tmux
    tmux-mem-cpu-load
    tmux-xpanes
    sesh # manager for tmux session
    tree
    tree-sitter
    watch
    wifi-password
    wget

    #Plugin para zsh
    zsh-fzf-history-search
    zsh-fzf-tab
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-autosuggestions-abbreviations-strategy
    zsh-autocomplete
    zsh-you-should-use

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    caddy
    gnupg
    cacert # Equivalente en hombrew de ca-certificates
    #zsh-powerlevel10k
    nodejs
    #pm2
    #ansible
    sqls  # LSP sql
    #nixfmt-classic # Formateador para nix

    # productivity
    glow # markdown previewer in terminal

    # K8S
    talosctl
    kubectl
    k9s
  ];

  # ver opciones de program en https://mynixos.com/home-manager/options/programs/2

  programs = {
    info.enable = true;

    bat = {
      enable = true;
      config = {
        #theme = "TwoDark";
        #theme = "Nightfox";
        theme = "Dracula";
        #theme = "Catppuccin-macchiato";
      };
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    htop.enable = true;

    gpg.enable = true;

    lazygit = { enable = true; };

    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };

    tealdeer = {
      enable = true;
      settings = { updates = { auto_update = true; }; };
    };

    lf = {
      enable = true;

      settings = {
        preview = true;
        hidden = true;
        drawbox = true;
        icons = true;
        ignorecase = true;
      };
    };

    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    # En 23.11 cambio exa por eza
    eza = {
      enable = true;
      enableZshIntegration =
        true; # enableAliases fue sustiuida por enableZshIntegration
      git = true;
      icons = "auto";
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    # zellij = {
    #   enable = true;
    #   enableBashIntegration = false;
    #   enableZshIntegration = false;
    #   settings = {
    #     theme = "catppuccin-macchiato";
    #   };
    # };

    ripgrep = {
      enable = true;
      arguments = [ "--max-columns-preview" "--colors=line:style:bold" ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [ "--height 50%" "--border" ];
      tmux.enableShellIntegration = true;
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      #  enableBashIntegration = true;
      enableZshIntegration = true;
      defaultOptions = [ "--height 50%" "--prompt >" ];

    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      #enableNushellIntegration = true;
      options = [
        #"--no-aliases"
        "--cmd cd"
      ];
    };

    #yazi = {
    #  enable = true;
    #  enableZshIntegration = true;
    #};

    #thefuck = {
    #  enable = true;
    #  enableZshIntegration = true;
    #};

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;

    };

    # multi-shell multi-command argument completer
    carapace = {
      enable = true;
      enableZshIntegration = true;
      #enableNushellIntegration = true;
      package = pkgs.carapace;
    };

    # multi-shell history records SQLite
    atuin = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      package = pkgs.atuin;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = true;
        sync.records = true; # Enable sync v2 by Default
        sync_frequency =
          "5m"; # For example, 10s, 20m, 1h, etc. If set to 0, Atuin will sync after every command
        sync_address = "https://api.atuin.sh";
        search_mode =
          "fuzzy"; # Atuin supports “prefix”, “fulltext”, “fuzzy”, and “skim” search modes (Default fuzzy)
        enter_accept = false; # always inserts the selected command for editing
        #style = "auto"; # Possible values: auto, full and compact.
        #inline_height = 0; # height of the search window (Default 0)
        history_filter = [ "^clear" "^exit" ];
      };
    };

  };
}
