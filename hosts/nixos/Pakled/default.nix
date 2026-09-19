{
  inputs,
  pkgs,
  username,
  stateVersion,
  hostName,
  ...
}:
{
  imports = [ ./disk-config.nix ];

  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  boot.loader.grub.enable = true;

  hardware.enableRedistributableFirmware = true;

  users.users.${username} = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATI6SmHL4hl4jN2vryj8ec//GxEDdvvFr45Kg+hUdBU"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAAFThFqJMUPBTzhNAQ5XdVTWKEyoG9aiSZezfHxPFz"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale.enable = true;
  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    git
    helix
    pciutils
    ripgrep
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs hostName; };
    users.${username} = {
      home = {
        inherit stateVersion;
        username = username;
        homeDirectory = "/home/${username}";
      };
      imports = [ ../../../home/alexlauni.nix ];
      programs = {
        git.settings.user = {
          name = "Alex Launi";
          email = "dev@launi.me";
        };
        jujutsu.settings.user = {
          name = "Alex Launi";
          email = "dev@launi.me";
        };
      };
    };
  };

  system.stateVersion = stateVersion;
}
