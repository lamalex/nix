# Profile for personal machines.
{ username, ... }:
{
  homebrew.casks = [
    "chatgpt"
    "tailscale-app"
    "google-chrome"
    "discord"
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
