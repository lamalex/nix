{
  description = "Launi's system flake";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # OpenCode v2 branch
    opencode.url = "github:anomalyco/opencode/c310ef82f4688225d06e84d682a1871f5b6a2600";

    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Determinate Nix <-> nix-darwin integration: manages nix.enable = false,
    # /etc/nix/nix.custom.conf and /etc/determinate/config.json
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs = inputs@{ nixpkgs, nix-darwin, home-manager, nix-homebrew, ... }:
    let
      username = "alexlauni";
      system = "aarch64-darwin";
      stateVersion = "24.11";

      # Overlay to update container to 0.10.0
      containerOverlay = final: prev: {
        container = prev.container.overrideAttrs (oldAttrs: rec {
          version = "0.10.0";
          src = final.fetchurl {
            url = "https://github.com/apple/container/releases/download/${version}/container-${version}-installer-signed.pkg";
            hash = "sha256-xIHONVUk0DbDzdrH/SgeMXlNQGkL+aIfcy7z12+p/gg=";
          };
        });
      };

      # Every directory under hosts/darwin is a host; its name becomes the host name.
      darwinHosts = builtins.attrNames (
        nixpkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts/darwin)
      );

      mkDarwinConfiguration = hostName: nix-darwin.lib.darwinSystem {
        inherit system;

        specialArgs = {
          inherit inputs username stateVersion system;
        };

        modules = [
          # Determinate compatibility: this module disables nix-darwin's Nix
          # management for us (sets nix.enable = false)
          inputs.determinate.darwinModules.default

          ({ ... }: {
            determinateNix.enable = true;
            nixpkgs.overlays = [ containerOverlay ];

            networking.hostName = hostName;
            networking.localHostName = hostName;
            networking.computerName = hostName;
          })

          # Common macOS / nix-darwin settings
          ./hosts/common/darwin-common.nix
          ./hosts/common/common-packages.nix
          ./hosts/common/darwin-system-tweaks.nix

          # Homebrew
          nix-homebrew.darwinModules.nix-homebrew
          ./hosts/common/nix-homebrew.nix

          # Host-specific overrides
          ./hosts/darwin/${hostName}

          # Home Manager as a nix-darwin module
          home-manager.darwinModules.home-manager
          ({
            ... # (pkgs, lib, etc available if you want them)
          }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs hostName; };

            home-manager.users.${username} = {
              home.stateVersion = stateVersion;
              imports = [ ./home/${username}.nix ];
            };
          })
        ];
      };
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs darwinHosts mkDarwinConfiguration;
    };
}
