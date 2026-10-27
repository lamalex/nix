{ config, lib, pkgs, ... }:
let
  cfg = config.programs.rex;
in
{
  options.programs.rex = {
    enable = lib.mkEnableOption "the Rex desktop app, local server, and CLI";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../pkgs/rex { };
      defaultText = lib.literalExpression "pkgs.callPackage ../../pkgs/rex { }";
      description = "The Rex package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      (pkgs.callPackage ../../pkgs/update-rex { })
    ];

    # Updates come from the flake; Sparkle cannot replace a Nix store bundle.
    system.defaults.CustomUserPreferences."com.superlogical.rex" = {
      SUAutomaticallyUpdate = false;
      SUEnableAutomaticChecks = false;
    };
  };
}
