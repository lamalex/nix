{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/Zen.app"
      "/Applications/Ghostty.app"
      "/Applications/Discord.app"
      "/Applications/Slack.app"
      "/Applications/Obsidian.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/Spotify.app"
    ];
  };
}
