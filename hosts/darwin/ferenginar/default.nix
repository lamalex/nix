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

  homebrew.masApps = {
    "Keynote" = 409183694;
    "Numbers" = 409203825;
    "Pages" = 409201541;
    "Teams" = 6746640556;
  };

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
