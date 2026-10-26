# Profile for personal machines.
{ pkgs, inputs, system, username, ... }:
let
  pkgsMaster = import inputs.nixpkgs-master {
    inherit system;
    config.allowUnfree = true;
  };

  upstreamOpencode = inputs.opencode.packages.${system}.opencode.override {
    # The v2 branch's aarch64-darwin node-modules hash is currently stale.
    node_modules = inputs.opencode.packages.${system}.node_modules_updater.override {
      hash = "sha256-yCYPwLVy+or9iW9QpCO3e1D0yGDSiPB9dx94Llt7M6o=";
    };
  };
  opencodeV2 = pkgs.runCommand "opencode-v2-${upstreamOpencode.version}" { } ''
    mkdir -p $out/bin
    ln -s ${upstreamOpencode}/bin/opencode $out/bin/opencode-v2
  '';
in
{
  environment.systemPackages = [
    pkgsMaster.opencode
    opencodeV2
  ];

  homebrew.casks = [
    "chatgpt"
    "tailscale-app"
    "google-chrome"
    "discord"
  ];

  homebrew.brews = [
    "mas"
  ];

  homebrew.masApps = { };

  home-manager.users.${username} = {
    imports = [ ../../home/radicle.nix ];

    programs = {
      jujutsu.settings.user = {
        name = "Alex Launi";
        email = "dev@launi.me";
      };

      git.settings.user = {
        name = "Alex Launi";
        email = "dev@launi.me";
      };
    };
  };
}
