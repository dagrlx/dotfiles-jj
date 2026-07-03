{ pkgs, lib, ... }: {
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  # TODO Fell free to modify this file to fit your needs.
  #
  ##########################################################################

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    git
    just # use Justfile to simplify nix-darwin's commands
  ];

  environment.variables = {
    EDITOR = "nvim";
  };

  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  homebrew = {
    prefix = "/opt/homebrew";
    enable = true;
    global = {
    autoUpdate = false;
    brewfile = true;
    };
    #macOS pone en cuarentena las aplicaciones descargadas de internet para mayor seguridade
    # caskArgs.no_quarantine = true;

    onActivation = {
      # Controla si Homebrew se auto-actualiza a sí mismo y a todas las fórmulas durante la activación del sistema
      # Nix-darwin
      autoUpdate = true;
      # Controla si se deben actualizar las fórmulas de Homebrew durante la activación del sistema Nix-darwin.
      upgrade = true;
      # Type: one of “none”, “check”, “uninstall”, “zap”
      # 'zap': uninstalls all formulae(and related files) not listed here
      cleanup = "uninstall";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    #masApps = {
    # TODO Feel free to add your favorite apps here.

    #Xcode = 497799835;
    #"WireGuard" = 1451685025;
    #"Tomito" = 1526042937;
    #"Windows App" = 1295203466;
    #"CotEditor" = 1024640650;
    #"MegaIPTVmacOS" = 1494386779;
    #"Airmail" = 918858936;
    #"Magnet" = 441258766;
    #"ScreenBrush" = 1233965871;
    #"Amphetamine" = 937984704;
    #"The Unarchiver" = 425424353;
    #"You Search" = 1641136636;
    #};

    taps = [
      {
        name = "FelixKratz/formulae";
        trusted = true;
      }
      {
        name = "jzelinskie/duckdns";
        trusted = true;
      }
      {
        name = "gromgit/fuse";
        trusted = true;
      }
      {
        name = "nikitabobko/tap";
        trusted = true;
      }
      {
        name = "BarutSRB/tap";
        trusted = true;
      }
      {
        name = "guria/tap";
        trusted = true;
      }
      {
        name = "acsandmann/tap";
        trusted = true;
      }
      {
        name = "netbirdio/tap";
        trusted = true;
      }
      {
        name = "olets/tap";
        trusted = true;
      }
      {
        name = "lihaoyun6/tap";
        trusted = true;
      }
      {
        name = "TheZoraiz/ascii-image-converter";
        trusted = true;
      }
      {
        name = "alienator88/cask";
        trusted = true;
      }
      {
        name = "pkgxdev/made";
        trusted = true;
      }
      {
        name = "mhaeuser/mhaeuser";
        trusted = true;
      } # battery-toolkit
      {
        name = "sinelaw/fresh";
        trusted = true;
      }
      {
        name = "manaflow-ai/cmux";
        trusted = true;
      }
      {
        name = "hewigovens/tap";
        trusted = true;
      } # jayjay (jj)
      {
        name = "tw93/tap";
        trusted = true;
      }
      {
        name = "anomalyco/tap";
        trusted = true;
      } # opencode
      {
        name = "iliyami/macsai";
        trusted = true;
      }
       {
        name = "sh4dow-clone/tap";
        trusted = true;
      } 


    ];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [
      "wget" # download tool
      "curl" 
      "aria2" # download tool
      "httpie" # http client
      "duckdns"
      "iproute2mac"
      "coreutils"
      "ansible"
      "scrcpy"
      "fastfetch" # Reemplazo neofecht
      "thefuck" # magnificent app that corrects your previous console command
      "tabiew" # Lector de archvio csv con consultas sql"
      "duckdb"
      "mole"
      "awscli"
      "minio-mc"
      "stu" # TUI explorer for S3
      "carapace"
      "direnv"
      "perl"
      "rclone"
      "sniffnet"
      "btop" # monitoreo de recursos
      "sshs" # List and connect to hosts using ~/.ssh/config.
      

      # CONTAINERS Y VM
      "podman"
      "podlet"
      "lima"
      # "container" # Native container of Macos 
      # "container-compose"

      # PLUGINS ZSH
      "zsh-abbr"
      "zsh-autocomplete"
      "zsh-syntax-highlighting"
      "zsh-autosuggestions"
      "zsh-autosuggestions-abbreviations-strategy"

      # EDITORES
      "nano"
      "nanorc"
      "neovim"
      "bob" # Neovim version manager
      "fresh-editor"

      # FILEMANAGER
      "superfile"
      #"broot"
      "yazi" # file manager
      "ascii-image-converter"

      # Dependencias opcionales para yazi
      "ffmpeg-full"
      "sevenzip"
      "poppler" # para PDF preview en yazi
      "jq"
      "fd"
      "resvg"
      "imagemagick-full"

      # COMPLEMENTOS PARA NEOVIM
      "lua"
      "luacheck"
      #"luarocks"
      #"lua-language-server"
      "ghostscript"
      "tree-sitter"
      "tree-sitter-cli"
      "go"
      "rust"

      # "sketchybar"
      # "switchaudio-osx"
      # "nowplaying-cli"
      # "borders"
      # "rift"

      "nushell"
      "fish"
      "fisher"

      #CONTROL VERSIONES - DOTFILES
      #"chezmoi"
      "stow"
      "jj" # jujutsu
      #"yadm"
      "age" # Is a simple, modern and secure file encryption tool, format, and Go library.
      #"atuin" # Shell history with SQLite
      "gh" # github cli. Se usa en pluing git sketchybar

      "talosctl"
      #"ntfs-3g-mac"

      # AGENTES, CHAT PARA LLM, TOOLS
      # "aichat" # all-in-one LLM CLI tool featuring Shell Assistant, CMD & REPL Mode, RAG, AI Tools & Agents, and More.
      "opencode"
      "herdr" # Multiplexor para agentes y sustitu de tmux

      "pam-reattach" # PAM module for reattaching to the user's GUI session (touchID)

      "pkgx" # Alternativa a hombrew
      "pkgm" # package manager of pkgx
      "deno" # Depedencia de pkgm
      "bun" # package manager, js, tyscript

      "kanata" # Excelente mapeador de teclado

      "pipx" # Install and Run Python Applications in Isolated Environments
      "uv" # An extremely fast Python package and project manager, written in Rust.

      "ffmpeg"
      "cloudflared"
    ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "firefox"
      #"zen" # zen-browser
      # always upgrade auto-updated or unversioned cask to latest version even if already installed
      #{
      #  name = "opera";
      #  greedy = true;
      #}
      {
        name = "deepl";
        greedy = true;
      }

      "vivaldi"

      # Desarrollo y scripts
      #"visual-studio-code"
      "zed"
      "devpod"
      # A native macOS GUI for Jujutsu
      "jayjay"  # hewigovens/tap/jayjay

      # "microsoft-teams"
      "microsoft-auto-update"
      "windows-app" # new app for RDP
      "syncthing-app" # file sync
      # "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      #"iglance" # beautiful system monitor
      "macfuse"
      "mounty"

      "vnc-viewer"

      #VPN
      # "zerotier-one"
      "tailscale-app"
      "netbird-ui"

      # Utilities
      "localsend"
      "landrop"
      "keka"
      "KnockKnock"
      #"kopiaui"
      #"kubecontext"
      "maintenance"
      "onyx"
      "deeper"
      "dockdoor"
      #"tyke" # App para tomar notas rapidas temporal
      #"applite" # App grafica homebrew - https://www.thriftmac.com
      "google-drive"
      # "battery-toolkit"
      "imageoptim" # optimizer image
      "betterdisplay"
      "uninstallpkg"
      # "ali-expandings/mactune/mactune"
      "hewigovens/tap/app-detective"
      "dpimanager"

      "brilliant"

      #"colemak-dh" # latout colemak mod DH

      "aerospace" # Tiling manager basado en i3wm
      "omniwm" # Tiling manager (niri, Hyprland Dwindle)
      # "guria/tap/nehir"  # Fork of omniwm (only niri)
      "guria/tap/nehir@rc"

      "MonitorControl"
      "pearcleaner" # mac app cleaner
      "sentinel-app" # A GUI for controlling Gatekeeper
      "mac-sai"
      "rclone-ui"
      #"ubersicht"

      #Terminales
      #"wave" # terminal con AI alternativa a warp y es software libre
      "kitty"
      "cmux"
      #"rio"

      "keepassxc"
      # "podman-desktop"
      #"slack"
      "teamviewer"
      "anydesk"
      "orbstack" # Docker y MV
      "appcleaner"
      #"diffusionbee" # Create Amazing Images Using AI
      #"authy"
      #"utm"
      "numi" # calculadora
      #"stats"
      #"qbittorrent"
      #"send-anywhere"
      "postman"
      "bruno" # Alternativa a postman

      # "telegram"
      #"whatsapp"
      "zoom"

      #"wireshark" # network analyzer
      "grandperspective" # Muestra de forma grafica el uso del disco
      "keycastr" # Muestra la pulsación de las teclas en pantalla
      "hyperkey"
      "karabiner-elements" # Permite modificar/crear teclado y combinaciones de teclas
      "vlc"
      "keyclu" # Muestra la lista de shortcut de las aplicaciones que se seleccione
      "cleanupbuddy" # Bloque teclado y mouse para poder hacer limpieza a la mac
      "displaylink"
      "obsidian"
      #"jordanbaird-ice" # Menu bar - Equivalente a bartender
      "thaw" # fork of ice 
      #"kap"
      #"cap"
      #"spaceman"
      #"raspberry-pi-imager"
      # "quickrecorder" # record screen
      "shottr"
      "shortcat" # Permite navegar iterfaz GUI con atajos

      #Fonts for sketchybar, wezterm

      # "font-sketchybar-app-font" # apps icons
      "font-hack-nerd-font" # Font for sketchybar
      "font-sf-pro" # Simbolos
      "sf-symbols" # iconos
      "font-sf-mono"
      "font-blex-mono-nerd-font"
      "font-symbols-only-nerd-font"

      ##### AI tool
      "lm-studio" # App for testing llms models
      "gpt4all"
      "ollama-app"

      "lulu" # firewwall for macOS
      "freelens" # for managing Kubernetes clusters

      #"fly" # Command line interface to Concourse CLI

      # OBS (Open Broadcaster Software)
      "obs"
      # "obs-advanced-scene-switcher"  # Obsoleto
      # "obs-backgroundremoval"  # Obsoleto

      "audacity"
    ];
  };
}
