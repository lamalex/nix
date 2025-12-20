{
  description = "Launi's system flake";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew, mac-app-util, ... }:
    let
      username = "alexlauni";
      system = "aarch64-darwin";
      stateVersion = "24.11";
    in
    {
      darwinConfigurations.ferenginar = nix-darwin.lib.darwinSystem {
        inherit system;

        specialArgs = {
          inherit inputs username stateVersion system;
        };

        modules = [
          # Determinate compatibility: nix-darwin must NOT manage Nix.
          ({ ... }: {
            nix.enable = false;
          })

          # Common macOS / nix-darwin settings
          ./hosts/common/darwin-common.nix
          ./hosts/common/common-packages.nix

          # Homebrew
          nix-homebrew.darwinModules.nix-homebrew
          ./hosts/common/nix-homebrew.nix

          # Optional (only if you actually use it)
          # mac-app-util.darwinModules.default

          # Host-specific overrides
          ./hosts/darwin/ferenginar/default.nix

          # Home Manager as a nix-darwin module
          home-manager.darwinModules.home-manager
          ({
            ... # (pkgs, lib, etc available if you want them)
          }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.${username} = {
              home.stateVersion = stateVersion;
              imports = [ ./home/${username}.nix ];
            };
          })
        ];
      };
    };
}
