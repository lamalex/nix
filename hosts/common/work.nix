# Profile for work machines.
{ username, ... }:
{
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
