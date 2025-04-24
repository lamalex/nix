{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [
    pkgs.arc-browser
    pkgs.ripgrep
    pkgs.gh
    pkgs.nixd
    pkgs.uv
    pkgs.du-dust
    pkgs.uutils-coreutils
    pkgs.tree
    pkgs.sd
    pkgs.dogdns
    # ripgrep
    # nixpkgs-unstable.legacyPackages.${pkgs.system}.beszel
    # nixpkgs-unstable.legacyPackages.${pkgs.system}.talosctl

    ## stable
    # act
    # ansible
    # btop
    # coreutils
    # diffr # Modern Unix `diff`
    # difftastic # Modern Unix `diff`
    # drill
    # du-dust # Modern Unix `du`
    # dua # Modern Unix `du`
    # duf # Modern Unix `df`
    # entr # Modern Unix `watch`
    # esptool
    # fastfetch
    # fd
    # ffmpeg
    # figurine
    # fira-code
    # fira-code-nerdfont
    # fira-mono
    # gh
    # git-crypt
    # gnused
    # go
    # hugo
    # iperf3
    # ipmitool
    # jetbrains-mono # font
    # jq
    # just
    # kubectl
    # mc
    # mosh
    # nerdfonts
    # nmap
    # qemu
    # skopeo
    # smartmontools
    # television
    # terraform
    # tree
    # unzip
    # watch
    # wget
    # wireguard-tools
    # zoxide

    # requires nixpkgs.config.allowUnfree = true;
    # vscode-extensions.ms-vscode-remote.remote-ssh
  ];
}
