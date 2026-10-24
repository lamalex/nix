{
  lib,
  stdenvNoCC,
  fetchurl,
  gzip,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "amp-cli";
  version = "0.0.1792872041-gb83e0b";

  src = fetchurl {
    url = "https://static.ampcode.com/cli/${finalAttrs.version}/amp-darwin-arm64.gz";
    hash = "sha256-0nJoxm8Wmrzgm0CE/6VSVquU/twq60Ur9mOWo95Lfes=";
  };

  nativeBuildInputs = [
    gzip
    makeWrapper
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec
    gzip -dc $src > $out/libexec/amp
    chmod +x $out/libexec/amp
    makeWrapper $out/libexec/amp $out/bin/amp \
      --set AMP_SKIP_UPDATE_CHECK 1

    runHook postInstall
  '';

  meta = {
    description = "Terminal coding agent and development environment";
    homepage = "https://ampcode.com/";
    license = lib.licenses.unfree;
    mainProgram = "amp";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
