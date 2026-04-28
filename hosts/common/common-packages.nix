{ pkgs, inputs, system, ... }:
let
  pkgsMaster = import inputs.nixpkgs-master {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.ripgrep
    pkgs.gh
    pkgs.fh
    pkgs.nixd
    pkgs.uv
    pkgs.dust
    pkgs.uutils-coreutils
    pkgs.tree
    pkgs.sd
    pkgs.pandoc
    pkgs.ghostty-bin
    pkgs.bottom
    pkgsMaster.opencode
    # Keep both until Apple container can cover Docker-style workflows.
    pkgs.container
    pkgs.podman
    pkgs.podman-compose
    pkgs.podman-desktop
    pkgs.glow
    pkgs.ouch
  ];
}
