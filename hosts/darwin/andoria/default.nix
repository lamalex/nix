{ lib, username, ... }:
{
  imports = [
    ../../common/darwin-system-tweaks.nix
  ];

  networking.hostName = "andoria";
  networking.localHostName = "andoria";
  networking.computerName = "andoria";

  services.openssh.enable = false;

  homebrew.masApps = lib.mkForce { };

  home-manager.users.${username}.programs = {
    jujutsu.settings.user = {
      name = "Alex Launi";
      email = "alauni@actblue.com";
    };

    git.settings.user = {
      name = "Alex Launi";
      email = "alauni@actblue.com";
    };
  };

  # Any host-only quirks:
  # - machine-specific paths
  # - docking / UI defaults unique to this device
  # - per-host packages
}
