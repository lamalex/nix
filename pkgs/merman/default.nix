{ lib, buildNpmPackage, fetchurl, bun, makeWrapper }:

buildNpmPackage rec {
  pname = "merman";
  version = "0.1.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/@kitlangton/merman/-/merman-${version}.tgz";
    hash = "sha512-vMkSVOttfUwEhNz9BdL6GtpwD6xOEjBlcB8zhStnJfjQNlXT1FEjo1GC8aTZRUjqhwf5Do7G2y7XNiaayhtrJA==";
  };

  # Upstream ships only bun.lock; vendor a generated npm lockfile so
  # buildNpmPackage can pin deps. Regenerate with:
  #   npm install --package-lock-only --ignore-scripts
  # against the same tarball, then recompute npmDepsHash with prefetch-npm-deps.
  # @opentui/core is declared as a peer + devDep upstream, so `npm prune
  # --omit=dev` drops it from the install output. Override the prune step
  # to keep dev deps (which include the peer) in the final node_modules.
  npmPruneFlags = [ "--include=dev" ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-HKl2mbZojEak+GXg0Y8v3Ml19eHXYyxuekY5EvZhsQo=";

  # dist/ is pre-built in the published tarball.
  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  # The shipped bin/merman.js uses `#!/usr/bin/env bun`. Replace the
  # auto-installed shim with a wrapper that invokes our bun on the entrypoint.
  postInstall = ''
    rm -f $out/bin/merman
    makeWrapper ${bun}/bin/bun $out/bin/merman \
      --add-flags "$out/lib/node_modules/@kitlangton/merman/bin/merman.js"
  '';

  meta = {
    description = "Mermaid-flavored flowchart, sequence, and state diagrams for OpenTUI terminals";
    homepage = "https://github.com/kitlangton/merman";
    license = lib.licenses.mit;
    mainProgram = "merman";
    platforms = lib.platforms.unix;
  };
}
