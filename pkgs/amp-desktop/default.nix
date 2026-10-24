{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zip-zstd,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "amp-desktop";
  version = "1.0-884";

  src = fetchurl {
    url = "https://static.ampcode.com/mac/Amp-${finalAttrs.version}.dmg";
    hash = "sha256-RJtnGjVoaBbG7dlt7IzpqqaGYq0Ll3dFDX0UD+GzjYQ=";
  };

  # Amp's DMG uses APFS, which the standard undmg hook cannot extract.
  nativeBuildInputs = [ _7zip-zstd ];

  unpackPhase = ''
    runHook preUnpack
    7zz x -snld $src 'Amp.app/*'
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -a Amp.app $out/Applications

    runHook postInstall
  '';

  meta = {
    description = "Native macOS client for the Amp coding agent";
    homepage = "https://ampcode.com/";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
