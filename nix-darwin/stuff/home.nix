{
  config,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dgarciar";
  home.homeDirectory = "/Users/dgarciar";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # Permite la instalacion de paquete no free pero solo desde dentro de HM
  nixpkgs.config = {
    allowUnfree = true;
    #allowUnfreePredicate = _: true;
    allowUnfreePredicate = pkg: true;
  };
  # nixpkgs.config.allowUnfreePredicate = (pkg: true);
  #nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowBroken = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    android-tools
    ansible
    aria # lightweight multi-protocol & multi-source command-line download utility
    # bat
    bottom
    cacert # Equivalente en hombrew de ca-certificates
    cheat
    coreutils-full
    curl
    # direnv
    dive
    #drawio ## El paquete esta roto
    duf
    du-dust
    # exa
    fping
    fzf-zsh
    git
    gnugrep
    hello-unfree
    httpie
    iterm2
    #    keepassxc
    kopia
    kubectl
    k9s
    lf
    mas # Mac App Store command-line interface
    mc
    minikube
    nano
    nanorc
    nmap
    nnn
    ntfs3g
    p7zip # Equivalente a 7-zip
    perl
    podman
    podman-compose
    pixman
    #    pkgs.podman-desktop ## da error - version vieja
    #    pkgs.raycast # no free licencia
    #    pkgs.realvnc-vnc-viewer ## no disponible arch64 mac
    readline
    ripgrep
    scrcpy
    sniffnet
    sqlite
    syncthing
    tailscale
    talosctl
    tealdeer #A very fast implementation of tldr in Rust
    tmux-mem-cpu-load
    tmux-xpanes
    tree
    tree-sitter
    vagrant
    vimPlugins.catppuccin-nvim
    watch
    wifi-password
    wget
    #    pkgs.zerotierone ## genera dependencia de iproute2 y este solo esta para linux
    #    zsh
    antigen
    #    zplug
    #    zsh-autosuggestions
    #    zsh-completions
    #    zsh-syntax-highlighting
    #    pkgs.docker
    #    pkgs.docker-compose
    #    pkgs.docker-machine

    # imports = [
    #  ./apps/zsh.nix
    # ];

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    #".nanorc".source = ./nanorc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dgarciar/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nano";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.command-not-found.enable = true;

  programs.gpg.enable = true;

  programs.exa = {
    enable = true;
    #enableAliases = true;
  };

  programs.info.enable = true;

  programs.htop.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
  };

  programs.dircolors.enable = true;

  programs.bat.enable = true;
  #programs.bat.config = {
  #  theme = "ansi-dark";
  #};

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    withPython3 = true;
    # extraConfig = builtins.readFile ./home/extraConfig.vim;
    extraConfig = "colorscheme catppuccin-mocha";
    plugins = with pkgs.vimPlugins; [
      #  auto-pairs
      #  fzf-vim
      vim-nix
      gruvbox
      catppuccin-nvim
      indentLine
    ];
  };

  programs.zsh = {
    enable = true;
    # enableAutosuggestions = true;
    # enableCompletion = true;
    initExtra = builtins.readFile ./zshrc;
  };

  #programs.git = {
  #  enable = true;
  #  userName = "dgarlx";
  #  userEmail = "dagrlx@gmail.com";
  #  aliases = {
  #    pu = "push";
  #    co = "checout";
  #    cm = "commit";

  programs.fzf = {
    enable = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs. readline = {
    enable = true;
  };

  # Un reemplazo de ls
  #programs.pls = {
  #  enable = true;
  #  enableAliases = true;
  #};

  home.shellAliases = {
    g = "git";
    "..." = "cd ../..";
  };
}
