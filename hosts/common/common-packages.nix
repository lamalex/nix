{ pkgs, ... }:
let
  opencodePatched = pkgs.opencode.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or []) ++ [
      ./opencode-anthropic-tools.patch
    ];
  });
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
    pkgs.devenv
    pkgs.pandoc
    opencodePatched
    pkgs.ghostty-bin
    pkgs.bottom
    pkgs.google-chrome
  ];
}
