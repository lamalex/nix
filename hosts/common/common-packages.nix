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
    pkgs.container
    pkgs.glow
    pkgs.ouch
  ];
}

