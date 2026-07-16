{
  description = "Launi's system flake";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # OpenCode v1.18.2
    opencode.url = "github:anomalyco/opencode/70b56a0a93d366889cae950379cc9d2537148fa2";

    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ nix-darwin, home-manager, nix-homebrew, ... }:
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

      mkDarwinConfiguration = hostPath: nix-darwin.lib.darwinSystem {
        inherit system;

        specialArgs = {
          inherit inputs username stateVersion system;
        };

        modules = [
          # Determinate compatibility: nix-darwin must NOT manage Nix.
          ({ ... }: {
            nix.enable = false;
            nixpkgs.overlays = [ containerOverlay ];
          })

          # Common macOS / nix-darwin settings
          ./hosts/common/darwin-common.nix
          ./hosts/common/common-packages.nix

          # Homebrew
          nix-homebrew.darwinModules.nix-homebrew
          ./hosts/common/nix-homebrew.nix

          # Host-specific overrides
          hostPath

          # Home Manager as a nix-darwin module
          home-manager.darwinModules.home-manager
          ({
            ... # (pkgs, lib, etc available if you want them)
          }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.${username} = {
              home.stateVersion = stateVersion;
              imports = [ ./home/${username}.nix ];
            };
          })
        ];
      };
    in
    {
      darwinConfigurations.ferenginar = mkDarwinConfiguration ./hosts/darwin/ferenginar/default.nix;
      darwinConfigurations.andoria = mkDarwinConfiguration ./hosts/darwin/andoria/default.nix;
    };
}
