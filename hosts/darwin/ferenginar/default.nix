{ username, ... }:
{
  imports = [
    ../../common/darwin-system-tweaks.nix
  ];

  networking.hostName = "ferenginar";
  networking.localHostName = "ferenginar";
  networking.computerName = "ferenginar";

  homebrew.casks = [
    "tailscale-app"
  ];

  homebrew.brews = [
    "mas"
  ];

  homebrew.masApps = {};

  home-manager.users.${username}.programs = {
    jujutsu.settings.user = {
      name = "Alex Launi";
      email = "dev@launi.me";
    };

    git.settings.user = {
      name = "Alex Launi";
      email = "dev@launi.me";
    };
  };

  # Any host-only quirks:
  # - machine-specific paths
  # - docking / UI defaults unique to this device
  # - per-host packages
}
