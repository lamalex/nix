{ lib, pkgs, username, ... }:
{
  imports = [ ../../common/work.nix ];

  environment.systemPackages = with pkgs; [
    k9s
  ];

  services.openssh.enable = false;

  homebrew.masApps = lib.mkForce { };

  home-manager.users.${username}.programs = {
    claude-code.enable = true;
  };

  # Any host-only quirks:
  # - machine-specific paths
  # - docking / UI defaults unique to this device
  # - per-host packages
}
