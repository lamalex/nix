{ config, pkgs, ... }:
let
  radicleEnv = pkgs.writeText "radicle.env" ''
    RAD_PASSPHRASE="op://Private/y4otqjyak3yjue5e6flr56jqhq/password"
  '';
in
{
  home.packages = [ pkgs.radicle-node ];

  launchd.agents.radicle-node = {
    enable = true;
    config = {
      ProgramArguments = [
        "/opt/homebrew/bin/op"
        "run"
        "--env-file=${radicleEnv}"
        "--"
        "${pkgs.radicle-node}/bin/radicle-node"
        "--force"
      ];
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
      ThrottleInterval = 30;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/.radicle/node-stdout.log";
      StandardErrorPath = "${config.home.homeDirectory}/.radicle/node-stderr.log";
    };
  };

  home.file.".radicle/config.json".text = builtins.toJSON {
    publicExplorer = "https://radicle.network/nodes/$host/$rid$path";
    preferredSeeds = [
      "z6MkqG2Ja8sGo6fmD4ukK6SGG7MPpn1beS8UJL64pSPa1wwb@seed.composting.me:8776"
      "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@iris.radicle.network:8776"
      "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@irisradizskwweumpydlj4oammoshkxxjur3ztcmo7cou5emc6s5lfid.onion:8776"
      "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosa.radicle.network:8776"
      "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosarad5bxgdlgjnzzjygnsxrwxmoaj4vn7xinlstwglxvyt64jlnhyd.onion:8776"
    ];
    cli.hints = true;
    node = {
      alias = "glenn🐉";
      listen = [ ];
      peers.type = "dynamic";
      connect = [
        "z6MkqG2Ja8sGo6fmD4ukK6SGG7MPpn1beS8UJL64pSPa1wwb@seed.composting.me:8776"
      ];
      externalAddresses = [ ];
      network = "main";
      log = "INFO";
      relay = "auto";
      limits = {
        routingMaxSize = 1000;
        routingMaxAge = 604800;
        gossipMaxAge = 1209600;
        fetchConcurrency = 1;
        maxOpenFiles = 4096;
        rate = {
          inbound = {
            fillRate = 5.0;
            capacity = 1024;
          };
          outbound = {
            fillRate = 10.0;
            capacity = 2048;
          };
        };
        connection = {
          inbound = 128;
          outbound = 16;
        };
        fetchPackReceive = "500.0 MiB";
        fetchTimeout = 30;
      };
      workers = 8;
      seedingPolicy.default = "block";
    };
  };
}
