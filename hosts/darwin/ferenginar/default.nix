{ ... }:
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

  # Any host-only quirks:
  # - machine-specific paths
  # - docking / UI defaults unique to this device
  # - per-host packages
}
