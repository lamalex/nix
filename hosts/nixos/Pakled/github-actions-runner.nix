{ pkgs, ... }:

let
  runnerName = "pakled-01";
  runnerTokenFile = "/var/lib/github-runner/yaffle.token";
  atticEnvironmentFile = "/var/lib/atticd-secret/atticd.env";
in
{
  # The token is deliberately provisioned out-of-band so it never enters the
  # Nix store. It must be a fine-grained PAT with organization self-hosted
  # runner read/write permission and contain no trailing newline.
  systemd.tmpfiles.rules = [
    "d /var/lib/github-runner 0700 root root -"
    "d /var/lib/atticd-secret 0700 root root -"
  ];

  environment.systemPackages = [ pkgs.openssl ];

  services.github-runners.yaffle = {
    enable = true;
    name = runnerName;
    url = "https://github.com/yaffle-dot-dev";
    tokenFile = runnerTokenFile;
    tokenType = "access";
    runnerGroup = "yaffle-build-farm";
    extraLabels = [
      "nixos"
      "yaffle-build"
    ];
    ephemeral = true;
    replace = true;

    # Keep the upstream dynamic user and systemd sandbox. The ephemeral runner
    # gets a fresh runtime directory and GitHub registration for every job.
    extraPackages = with pkgs; [
      curl
      attic-client
      jq
      openssh
      unzip
    ];
  };

  # Allow the host to activate before its runner credential is provisioned.
  # Starting/restarting the unit after writing the token registers the runner.
  systemd.services.github-runner-yaffle.unitConfig.ConditionPathExists = runnerTokenFile;

  # Pakled's 1 TB SSD is large enough to colocate a small-farm binary cache.
  # Attic uses SQLite and local storage here; both live below /var/lib/atticd
  # and are owned independently from the ephemeral runner.
  services.atticd = {
    enable = true;
    mode = "monolithic";
    environmentFile = atticEnvironmentFile;
    settings = {
      listen = "0.0.0.0:8080";
      allowed-hosts = [
        "pakled:8080"
        "pakled.tail66f312.ts.net:8080"
      ];
      api-endpoint = "http://pakled:8080/";
      database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
      storage = {
        type = "local";
        path = "/var/lib/atticd/storage";
      };
      compression = {
        type = "zstd";
        level = 8;
      };
      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "3 months";
      };
    };
  };

  # Starting/restarting Attic after writing its environment file initializes
  # the service. Only tailnet peers can reach the plaintext HTTP endpoint; the
  # transport itself is encrypted by Tailscale.
  systemd.services.atticd.unitConfig.ConditionPathExists = atticEnvironmentFile;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8080 ];

  # Pakled has 12 GiB of RAM. Bound local Nix parallelism so a single job does
  # not starve the runner or force sustained swapping.
  nix.settings = {
    max-jobs = 2;
    cores = 4;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
