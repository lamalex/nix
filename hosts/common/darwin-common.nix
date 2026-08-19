{ inputs, config, username, pkgs, lib, ... }:
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

  # Custom Determinate Nix CLI settings, rendered to /etc/nix/nix.custom.conf
  # by the determinate module (Determinate owns /etc/nix/nix.conf itself).
  # NOTE: don't use determinateNix.registry — the module points the global
  # flake-registry at the generated file, which would break bare `nixpkgs#`
  # refs. The `u` pin lives in home/alexlauni.nix (user registry) instead.
  determinateNix.customSettings = {
    extra-substituters = [ "https://moonrepo.cachix.org" ];
    extra-trusted-substituters = [ "https://moonrepo.cachix.org" ];
    extra-trusted-public-keys = [ "moonrepo.cachix.org-1:n4zm4mkV1Eoqck4mQvAhJM28EQwFLU7kW4dEbtAXbD8=" ];
  };

  # Reload Determinate's nix-daemon when the custom nix config changes, so new
  # settings (substituters, ...) take effect without a manual kickstart.
  # nix-darwin's built-in daemon reload lives in its nix module, which is
  # disabled here (Determinate owns Nix). This runs in postActivation, before
  # /run/current-system is repointed, so it still sees the previous generation.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    if ! diff /etc/nix/nix.custom.conf /run/current-system/etc/nix/nix.custom.conf &> /dev/null; then
      echo "reloading determinate nix-daemon (nix.custom.conf changed)..." >&2
      launchctl kickstart -k system/systems.determinate.nix-daemon
    fi
  '';

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
      "ghostty"
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
