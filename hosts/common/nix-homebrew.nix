{ username, ... }:
{
  nix-homebrew = {
    enable = true;
    user = username;
    autoMigrate = true;
  };
}
