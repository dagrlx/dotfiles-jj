{ config, lib, pkgs, username,... }: {
let
  homeDirectory = "/Users/${username}";
  dotfilesPath = "${homeDirectory}/.dotfiles";
in
{
  programs.nushell = {
    enable = true;
    configFile.source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nushell/config.nu";
    envFile.source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nushell/env.nu";
  };
}
}
