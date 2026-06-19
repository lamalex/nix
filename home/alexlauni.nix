{ pkgs, lib, ... }:
let
  shellAliases = {
    cat = "${pkgs.bat}/bin/bat";
  };
in
{
  # Files
  xdg.configFile."ghostty/config".text = builtins.readFile ./ghostty/config;

  # Core CLI / shell tools
  programs.bash = {
    enable = true;
    shellAliases = shellAliases;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    shellAliases = shellAliases;
    initContent = ''
      # Copy bat completions to cat alias
      compdef cat=bat
    '';
    # initContent = builtins.readFile ../mac-dot-zshrc;
  };

  programs.fish = {
    enable = true;
    shellAliases = shellAliases;
    interactiveShellInit = ''
      # Copy bat completions to cat alias
      complete -c cat -w bat
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = pkgs.lib.importTOML ./starship/starship.toml;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    tmux.enableShellIntegration = true;
    defaultOptions = [ "--no-mouse" ];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--color=auto"
    ];
  };

  programs.fd.enable = true;
  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };
  programs.lf.enable = true;

  programs.bat = {
    enable = true;
    config.theme = "Nord";
  };

  # Editors
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  # Dev tooling
  programs.gpg.enable = true;

  programs.nushell = {
    enable = true;
    configFile.source = ./nu/config.nu;
  };

  programs.carapace = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = pkgs.lib.importTOML ./jj/config.toml;
  };

  programs.jjui = {
    enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = "openpgp";

    settings = {
      init.defaultBranch = "main";
      merge = {
        conflictStyle = "diff3";
        tool = "meld";
      };
      pull.rebase = true;
    };
  };

  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      mode = "difftool";
    };
    options.background = "dark";
  };

  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
  };

  targets.darwin.copyApps.enable = true;
  targets.darwin.linkApps.enable = false;

  # Indexing / completion
  programs.home-manager.enable = true;

  # Pick ONE place to enable nix-index:
  # - If you enable it in nix-darwin, you can remove this.
  programs.nix-index.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "github.com" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
      };

      "*" = {
        StrictHostKeyChecking = "yes";
      };
    };
  };

  # macOS-only
  programs.aerospace = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
  };
}
