# Profile for work machines.
{ username, ... }:
{
  imports = [ ../../modules/darwin/rex.nix ];

  programs.rex.enable = true;

  home-manager.users.${username}.programs = {
    jujutsu.settings.user = {
      name = "Alex Launi";
      email = "alauni@actblue.com";
    };

    git.settings.user = {
      name = "Alex Launi";
      email = "alauni@actblue.com";
    };
  };
}
