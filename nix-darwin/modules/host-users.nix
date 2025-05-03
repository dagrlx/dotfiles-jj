{
  username,
  hostname,
  ...
} @ args:
#############################################################
#
#  Host & Users configuration
#
#############################################################
{
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
    shell = "/opt/homebrew/bin/nu";
  };
  
  # Lista de usuarios que están autorizados a conectarse al daemon de Nix.
  # Se puede asignar grupo ejemplo nix.settings.trusted-users = [ "@wheel" ];
  nix.settings.trusted-users = [username];
}
