{ inputs, outputs, stateVersion, ... }:
{
  mkDarwin = { hostname, username ? "alexlauni", system ? "aarch64-darwin",}:
  let
    inherit (inputs.nixpkgs) lib;
    customConfPath = ./../hosts/darwin/${hostname};
    customConf = if builtins.pathExists (customConfPath) then (customConfPath + "/default.nix") else ./../hosts/common/darwin-common-dock.nix;
  in
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = { inherit system inputs username; };
      modules = [
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = username;
            autoMigrate = true;
            
          };
        }
        {
          system.primaryUser = username;
          security.pam.services.sudo_local.touchIdAuth = true;
          environment.systemPackages = with inputs.nixpkgs; [
            inputs.nix-darwin.packages.${system}.darwin-rebuild
          ];
        }
        ../hosts/common/common-packages.nix
        ../hosts/common/darwin-common.nix
        customConf
        inputs.home-manager.darwinModules.home-manager {
            networking.hostName = hostname;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.${username} = {
              home.stateVersion = stateVersion;
              imports = [ ./../home/${username}.nix ];
            }; 
        }


      ];
    };
}
