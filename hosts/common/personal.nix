# Profile for personal machines.
{ username, ... }:
{
  homebrew.casks = [
    "chatgpt"
    "tailscale-app"
  ];

  homebrew.brews = [
    "mas"
  ];

  homebrew.masApps = { };

  home-manager.users.${username}.programs = {
    jujutsu.settings.user = {
      name = "Alex Launi";
      email = "dev@launi.me";
    };

    git.settings.user = {
      name = "Alex Launi";
      email = "dev@launi.me";
    };
  };
}
