{
  description = "Launi's system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";

    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, mac-app-util, determinate, ... }@inputs:
    with inputs;
    let
      inherit (self) outputs;
      stateVersion = "24.11"; # Home-Manager stateVersion (string)
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in {
      darwinConfigurations = {
        ferenginar = libx.mkDarwin { hostname = "ferenginar"; };
      };
      # Home-Manager is enabled from mkDarwin via home-manager.darwinModules.home-manager
    };
}

