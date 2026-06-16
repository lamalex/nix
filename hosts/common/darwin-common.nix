{ inputs, config, username, pkgs, ... }:
{
  system.stateVersion = 5;

  system.primaryUser = username;

  users.users.${username} = {
    home = "/Users/${username}";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    lima
    defaultbrowser
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
    nerd-fonts.droid-sans-mono
  ];

  # NOTE: With nix.enable = false, nix-darwin may not be the authority for Nix config.
  # If you find this registry isn't taking effect, move it to user-level (Home Manager)
  # or your Determinate configuration.
  nix.registry.u.to = {
    type = "path";
    path = inputs.nixpkgs;
  };

  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    global.autoUpdate = true;

    casks = [
      "discord"
      "ghostty"
      "google-chrome"
      "raycast"
      "slack"
      "spotify"
      "1password"
      "1password-cli"
      "visual-studio-code"
    ];

  };

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  system.activationScripts.userTweaks.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
    su -l ${config.system.primaryUser} -c '${pkgs.defaultbrowser}/bin/defaultbrowser browser || true'
  '';
}
