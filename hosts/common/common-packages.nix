{ pkgs, inputs, system, ... }:
let
  pkgsMaster = import inputs.nixpkgs-master {
    inherit system;
    config.allowUnfree = true;
  };

  upstreamOpencode = inputs.opencode.packages.${system}.opencode;
  opencodeV2 = pkgs.runCommand "opencode-v2-${upstreamOpencode.version}" { } ''
    mkdir -p $out/bin
    ln -s ${upstreamOpencode}/bin/opencode $out/bin/opencode-v2
  '';

  hunkVersion = "0.10.0";
  hunkArtifacts = {
    aarch64-darwin = {
      directory = "hunkdiff-darwin-arm64";
      url = "https://github.com/modem-dev/hunk/releases/download/v${hunkVersion}/hunkdiff-darwin-arm64.tar.gz";
      hash = "sha256-cdiwcZPevnbhlpsHzPeRVsb5WQdunaNlTCKh+XwarUU=";
    };
    x86_64-darwin = {
      directory = "hunkdiff-darwin-x64";
      url = "https://github.com/modem-dev/hunk/releases/download/v${hunkVersion}/hunkdiff-darwin-x64.tar.gz";
      hash = "sha256-70O4DI3+7ZuZstem8QeiL/qrj9M65nYVflqzqUlpnSY=";
    };
    aarch64-linux = {
      directory = "hunkdiff-linux-arm64";
      url = "https://github.com/modem-dev/hunk/releases/download/v${hunkVersion}/hunkdiff-linux-arm64.tar.gz";
      hash = "sha256-epaG0urTx3nqr2mIClkDLzrxf+gOZE4EDyC0YyEPq8M=";
    };
    x86_64-linux = {
      directory = "hunkdiff-linux-x64";
      url = "https://github.com/modem-dev/hunk/releases/download/v${hunkVersion}/hunkdiff-linux-x64.tar.gz";
      hash = "sha256-ND3Kb1u0B5O+joNCvE4LzJjYpSFnt5QWDFGmuAmYns8=";
    };
  };
  hunkArtifact =
    hunkArtifacts.${pkgs.stdenv.hostPlatform.system}
      or (throw "Unsupported system for hunk: ${pkgs.stdenv.hostPlatform.system}");
  hunk = pkgs.stdenvNoCC.mkDerivation {
    pname = "hunk";
    version = hunkVersion;

    src = pkgs.fetchurl {
      inherit (hunkArtifact) url hash;
    };

    sourceRoot = hunkArtifact.directory;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 hunk $out/bin/hunk
      runHook postInstall
    '';

    meta = {
      description = "Review-first terminal diff viewer";
      homepage = "https://github.com/modem-dev/hunk";
      license = pkgs.lib.licenses.mit;
      mainProgram = "hunk";
      platforms = builtins.attrNames hunkArtifacts;
    };
  };
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.ripgrep
    pkgs.gh
    pkgs.fh
    pkgs.nixd
    pkgs.uv
    pkgs.dust
    pkgs.uutils-coreutils
    pkgs.tree
    pkgs.sd
    pkgs.pandoc
    pkgs.bottom
    pkgsMaster.opencode
    opencodeV2
    # Keep both until Apple container can cover Docker-style workflows.
    pkgs.container
    pkgs.orbstack
    pkgs.glow
    pkgs.ouch
    hunk
  ];
}
