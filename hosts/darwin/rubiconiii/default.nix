{ pkgs, ... }:
{
  imports = [
    ../../common/personal.nix
    ../../../modules/darwin/amp.nix
  ];

  programs.amp.enable = true;

  environment.systemPackages = with pkgs; [
    signal-desktop
  ];

  # Any host-only quirks:
  # - machine-specific paths
  # - docking / UI defaults unique to this device
  # - per-host packages
}
