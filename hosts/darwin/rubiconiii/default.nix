{ pkgs, ... }:
{
  imports = [ ../../common/personal.nix ];

  environment.systemPackages = with pkgs; [
    signal-desktop 
  ];

  # Any host-only quirks:
  # - machine-specific paths
  # - docking / UI defaults unique to this device
  # - per-host packages
}

