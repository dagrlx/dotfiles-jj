# Ejemplo base tomado de https://github.com/ryan4yin/nix-darwin-kickstarter

{
  description = "Nix for macOS configuration";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];

    # Configuración de cachés binarias
    substituters = [
      "https://cache.nixos.org/"                # Caché oficial de NixOS
      "https://nix-community.cachix.org/"       # Caché de nix-community (útil para Home Manager)
      "https://nix-darwin.cachix.org/"          # Caché de Nix-Darwin
      #"https://python.cachix.org/"              # Caché específica para Python"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="  # Clave para cache.nixos.org
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-darwin.cachix.org-1:LxMyKzQk7Uqkc1Pfq5uhm9GSn07xkERpy+7cpwc006A="
      #"python.cachix.org-1:K94G3Q5J4yvIeRlLX0t0Qw=="
    ];

  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  # repositorio nixpkgs-unstable es rolling release
  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    #nixpkgs.url = "github:NixOS/nixpkgs/9e99614bc8c851fed28294feebd31d096e9804d6"; # Commit del build 293267388
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # home-manager, used for managing user configuration
    home-manager = {
      #url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-utils.url = "github:numtide/flake-utils";

  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, ... }:
    let
      # TODO replace with your own username, email, system, and hostname
      config = import ./datos.nix;
      username = config.username;
      useremail = config.useremail;
      system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin
      hostname = config.hostname;

      specialArgs = inputs // { inherit username useremail hostname; };
    in {
      darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nix-core.nix
          ./modules/system.nix
          ./modules/apps.nix
          ./modules/host-users.nix

          # home manager
          home-manager.darwinModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username} = import ./home;
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      #darwinPackages = self.darwinConfigurations.${hostname}.pkgs;

      # nix code formatter
      formatter.${system} = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    };
}
