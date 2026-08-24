{ config, pkgs, lib, hostName, inputs, ... }:
let
  shellAliases = {
    cat = "${pkgs.bat}/bin/bat";
  };

  # Per-host SSH identity keys. Each is a separate SSH Key item in 1Password
  # named after the machine. 1Password syncs items to every device, so this
  # gives per-host identity on GitHub (audit trail + per-machine revocation),
  # not isolation — every key is reachable from every machine's agent.
  # To add a host: generate its key in 1Password, paste the public key here,
  # and upload it to GitHub (both as an authentication key and a signing key).
  hostKeys = {
    rubiconiii = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATI6SmHL4hl4jN2vryj8ec//GxEDdvvFr45Kg+hUdBU";
    andoria = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAAFThFqJMUPBTzhNAQ5XdVTWKEyoG9aiSZezfHxPFz";
    # ferenginar = "ssh-ed25519 ...";
  };
  thisHostKey =
    hostKeys.${hostName}
      or (builtins.throw "no SSH key defined for host '${hostName}' — add it to hostKeys in home/alexlauni.nix");
in
{
  # Files
  xdg.configFile."ghostty/config".text = builtins.readFile ./ghostty/config;

  home.file.".claude/CLAUDE.md" = lib.mkIf config.programs.claude-code.enable {
    text = ''
      Always use ASD-STE100 Simplified Technical English when responding or writing.
      Use `jj` over `git` for all vcs operations, provided `jj` has been initialized in the active repository.
    '';
  };

  # GitHub's published SSH host keys (https://api.github.com/meta), pinned so
  # StrictHostKeyChecking=yes works without trust-on-first-use. This file is
  # nix-managed (read-only) — add other hosts here as needed.
  home.file.".ssh/known_hosts".text = ''
    github.com,[ssh.github.com]:443 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    github.com,[ssh.github.com]:443 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com,[ssh.github.com]:443 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
  '';

  # Principals trusted for SSH commit-signature verification
  # (git log --show-signature): every host key, under both emails.
  home.file.".ssh/allowed_signers".text =
    lib.concatStringsSep "\n" (lib.concatMap (key: [
      "dev@launi.me ${key}"
      "alauni@actblue.com ${key}"
    ]) (lib.unique (builtins.attrValues hostKeys))) + "\n";

  # This machine's own public key — referenced by IdentityFile in the ssh
  # config so the host consistently uses its designated key from the agent.
  home.file.".ssh/${hostName}.pub".text = "${thisHostKey}\n";

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
    historyWidget.command = "";
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

    # Sign commits with this host's SSH key, stored in 1Password (TouchID)
    signing = {
      format = "ssh";
      key = thisHostKey;
      signByDefault = true;
    };

    settings = {
      init.defaultBranch = "main";
      merge = {
        conflictStyle = "diff3";
        tool = "meld";
      };
      pull.rebase = true;
      gpg.ssh = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        allowedSignersFile = "~/.ssh/allowed_signers";
      };
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
        # The agent offers every key in 1Password; pin this machine's own key
        IdentityFile = "~/.ssh/${hostName}.pub";
        IdentitiesOnly = "yes";
      };

      "*" = {
        StrictHostKeyChecking = "yes";
        # Use 1Password's SSH agent (TouchID) instead of the macOS agent
        IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
      };
    };
  };

  # Pin `u` to this flake's nixpkgs. Lives at user level (~/.config/nix/
  # registry.json) because nix-darwin's nix.registry is inert with
  # nix.enable = false, and determinateNix.registry would hijack the global
  # flake-registry (breaking bare `nixpkgs#` refs).
  nix.registry.u.to = {
    type = "path";
    path = inputs.nixpkgs;
  };

  # Point SSH_AUTH_SOCK at 1Password's agent too, for tools that don't read
  # ssh config (jj/libssh2, VS Code, ssh-add, ...)
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  # macOS-only
  programs.aerospace = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
  };
}
