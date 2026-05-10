{ pkgs, lib, ... }:

{
  # enable flakes globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Nix necesita saber dónde está el bundle
  nix.settings.ssl-cert-file = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  # Permite paquetes rotos
  #nixpkgs.config.allowBroken = true;

  # https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-nix.enable
  # defautl is true
  #nix.enable = true;

  # nix.package = pkgs.nixVersions.latest;
  nix.package = pkgs.lixPackageSets.stable.lix;
  #nix.package = pkgs.nixVersions.nix_2_21;

  programs.nix-index.enable = true;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    #dates = "weekly";
    interval = { Weekday = 0; Hour = 10; Minute = 0; };
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Manual optimise storage: nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  # Disable auto-optimise-store because of this issue:
  #   https://github.com/NixOS/nix/issues/7273
  # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists
  # (see https://github.com/NixOS/nix/issues/7273#issuecomment-2295429401)
  # Tip This option only applies to new files, so we recommend manually optimising your nix store when first setting this option.
  nix.optimise = {
    automatic = true;
    interval = [
      {
        Hour = 9;
        Minute = 30;
        Weekday = 0; # 0 is monday, 7 is sunday
      }
    ];
  };

  # The store can be optimised during every build.
  # If true, this may slow down builds, as discussedc here https://github.com/NixOS/nix/issues/6033
  # Depreciate option `nix.settings.auto-optimise-store` is known to corrupt the Nix Store, please use `nix.optimise.automatic` instead.
  nix.settings = { 
      auto-optimise-store = false;

    # Evita que Nix intente usar toda la RAM disponible en procesos de evaluación pesados
    max-jobs = "auto";
    cores = 0; # Deja que Nix decida, pero limita si notas lentitud

    # Ayuda a prevenir la fragmentación del disco y asegura espacio antes de escribir
    preallocate-contents = true;

    # Mejora la fiabilidad de las descargas si tienes una conexión inestable
    download-attempts = 5;
    connect-timeout = 5;

    # Relaja el sandbox si tienes problemas constantes con builds locales
     # sandbox = "relaxed"; 
  
    # O desactivarlo si prefieres fiabilidad de build sobre aislamiento total
    # sandbox = false;

      };

}
