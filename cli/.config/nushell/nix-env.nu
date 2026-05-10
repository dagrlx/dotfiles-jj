# use std/util "path add"
# path add "/etc/profiles/per-user/dgarciar/bin"

$env.PATH = [
    "/run/current-system/sw/bin"  # Debe de ir primero para usar ka version mas actual de nix 
    "/nix/var/nix/profiles/default/bin"
    $"/etc/profiles/per-user/($env.USER)/bin"
    $"($env.HOME)/.nix-profile/bin"
    "/usr/local/bin"
] ++ $env.PATH

$env.XDG_CONFIG_DIRS = [
    $"($env.HOME)/.nix-profile/etc/xdg"
    $"/etc/profiles/per-user/($env.USER)/etc/xdg"
    "/run/current-system/sw/etc/xdg"
    "/nix/var/nix/profiles/default/etc/xdg"
]  

$env.XDG_DATA_DIRS = [
    $"($env.HOME)/.nix-profile/share"
    $"/etc/profiles/per-user/($env.USER)/share"
    "/run/current-system/sw/share"
    "/nix/var/nix/profiles/default/share"
    "/usr/local/share"
    "/usr/share"
    "/Applications/Ghostty.app/Contents/Resources/ghostty/"
]

$env.NIX_USER_PROFILE_DIR = $"/nix/var/nix/profiles/per-user/($env.USER)"
$env.NIX_PROFILES = [
    "/nix/var/nix/profiles/default"
    "/run/current-system/sw"
    $"/etc/profiles/per-user/($env.USER)"
    $"($env.HOME)/.nix-profile"
]
   
# Variables específicas de Nix
$env.NIX_PATH = "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs"
$env.NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"

if ($"($env.HOME)/.nix-defexpr/channels" | path exists) {
    $env.NIX_PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.nix-defexpr/channels")
}

$env.EDITOR = "nvim"
$env.PATH = $env.PATH | append ~/.orbstack/bin

