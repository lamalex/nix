{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

let
  source = lib.importJSON ./source.json;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rex";
  inherit (source) version;

  src = fetchurl {
    url = "https://blob.superlogical.com/public/rex-app/snapshot/Rex-${finalAttrs.version}.dmg";
    inherit (source) hash;
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  # Keep the signed app and its embedded server unchanged.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -a "Rex Beta.app" "$out/Applications/"
    ln -s "$out/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex" "$out/bin/rex"

    runHook postInstall
  '';

  meta = {
    description = "Rex terminal workspace with a bundled local server and CLI";
    homepage = "https://www.superlogical.com/rex/docs/installation";
    license = lib.licenses.unfree;
    mainProgram = "rex";
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
