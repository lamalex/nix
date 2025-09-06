{
  description = "Launi's system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";



    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { ... }@inputs:
    with inputs;
    let
      inherit (self) outputs;
      stateVersion = "24.11";
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in {
      darwinConfigurations = {
        ferenginar = libx.mkDarwin { hostname = "ferenginar"; };
      };

      defaults = { lib, config, name, ... }: {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    };
}
