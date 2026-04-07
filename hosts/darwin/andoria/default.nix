{ ... }:
{
  networking.hostName = "andoria";
  networking.localHostName = "andoria";
  networking.computerName = "andoria";

  services.openssh.enable = false;

  # Any host-only quirks:
  # - machine-specific paths
  # - docking / UI defaults unique to this device
  # - per-host packages
}
