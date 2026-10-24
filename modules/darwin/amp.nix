{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.amp;
in
{
  options.programs.amp = {
    enable = lib.mkEnableOption "the Amp desktop app and terminal UI";

    cliPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../pkgs/amp-cli { };
      defaultText = lib.literalExpression "pkgs.callPackage ../../pkgs/amp-cli { }";
      description = "The Amp CLI package to install.";
    };

    desktopPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../pkgs/amp-desktop { };
      defaultText = lib.literalExpression "pkgs.callPackage ../../pkgs/amp-desktop { }";
      description = "The Amp desktop package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.cliPackage
      cfg.desktopPackage
    ];

    # The app lives in the immutable Nix store; updates are applied by changing
    # the pinned version and hash rather than by Sparkle replacing the bundle.
    system.defaults.CustomUserPreferences."com.ampcode.amp.macos" = {
      SUAutomaticallyUpdate = false;
      SUEnableAutomaticChecks = false;
    };
  };
}
