{ lib, writeShellApplication, python3, curl }:

writeShellApplication {
  name = "update-rex";
  runtimeInputs = [ curl ];
  text = ''
    exec ${python3}/bin/python3 ${./update_rex.py} "$@"
  '';

  meta = {
    description = "Update and verify this flake's pinned Rex release";
    mainProgram = "update-rex";
    platforms = lib.platforms.darwin;
  };
}
