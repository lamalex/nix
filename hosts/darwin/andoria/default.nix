{ lib, pkgs, username, ... }:
{
  imports = [
    ../../common/darwin-system-tweaks.nix
  ];

  environment.systemPackages = with pkgs; [
    k9s
  ];

  networking.hostName = "andoria";
  networking.localHostName = "andoria";
  networking.computerName = "andoria";

  services.openssh.enable = false;

  homebrew.masApps = lib.mkForce { };

  home-manager.users.${username}.programs = {
    claude-code.enable = true;

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
