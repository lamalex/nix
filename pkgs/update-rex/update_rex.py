"""Update the Rex pin only after building and verifying the candidate app."""

import argparse
import json
import os
import plistlib
import re
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path


RELEASE_ROOT = "https://blob.superlogical.com/public/rex-app/snapshot/"
# The query avoids a cached Brotli response served without content negotiation.
FEED_URL = RELEASE_ROOT + "appcast.xml?format=xml"
SPARKLE = "{http://www.andymatuschak.org/xml-namespaces/sparkle}"
VERSION = re.compile(r"([0-9]+(?:\.[0-9]+)*)-([0-9]+)")
SIGNER_REQUIREMENT = (
    'anchor apple generic and identifier "com.superlogical.rex" '
    'and certificate leaf[subject.OU] = "AG92C3PT77"'
)


def run(*args):
    return subprocess.run(
        args, check=True, text=True, stdout=subprocess.PIPE
    ).stdout.strip()


def latest_release(feed):
    """Select a full DMG by numeric build number, regardless of feed ordering."""
    releases = []
    for item in ET.fromstring(feed).findall("./channel/item"):
        build = item.findtext(SPARKLE + "version", "").strip()
        short = item.findtext(SPARKLE + "shortVersionString", "").strip()
        version = f"{short}-{build}"
        if not VERSION.fullmatch(version):
            raise ValueError(f"Unrecognized Rex release version: {version!r}")
        url = RELEASE_ROOT + f"Rex-{version}.dmg"
        if any(e.get("url") == url for e in item.findall("enclosure")):
            releases.append((int(build), version, url))
    if not releases:
        raise ValueError("Rex feed contains no full DMG from the official snapshot URL")
    _, version, url = max(releases)
    return version, url


def find_flake(directory):
    directory = Path(directory).resolve()
    for root in (directory, *directory.parents):
        if (root / "flake.nix").is_file() and (root / "pkgs/rex/source.json").is_file():
            return root
    raise ValueError("Run from this flake's checkout or pass its directory")


def nix_string(value):
    return json.dumps(str(value), ensure_ascii=False).replace("${", r"\${")


def build_candidate(root, source, temporary):
    """Build with the checkout's locked nixpkgs, without editing the checkout."""
    candidate = temporary / "rex"
    candidate.mkdir()
    (candidate / "default.nix").write_bytes((root / "pkgs/rex/default.nix").read_bytes())
    (candidate / "source.json").write_text(json.dumps(source) + "\n")
    expression = f"""
      let
        flake = builtins.getFlake {nix_string('path:' + str(root))};
        pkgs = import flake.inputs.nixpkgs {{
          system = builtins.currentSystem;
          config.allowUnfree = true;
        }};
      in pkgs.callPackage (builtins.toPath {nix_string(candidate)}) {{}}
    """
    output = run(
        "nix", "build", "--impure", "--no-write-lock-file", "--no-link",
        "--print-out-paths", "--expr", expression,
    )
    return Path(output)


def verify_package(package, version):
    app = package / "Applications/Rex Beta.app"
    # Verify every nested signature, then require the main app's vendor identity.
    run("/usr/bin/codesign", "--verify", "--deep", "--strict", str(app))
    run(
        "/usr/bin/codesign", "--verify", "--strict", "--test-requirement",
        "=" + SIGNER_REQUIREMENT, str(app),
    )
    with (app / "Contents/Info.plist").open("rb") as handle:
        info = plistlib.load(handle)
    actual = f"{info['CFBundleShortVersionString']}-{info['CFBundleVersion']}"
    if actual != version:
        raise ValueError(f"Downloaded app is {actual}, expected {version}")
    print(run(str(package / "bin/rex"), "version"))


def write_pin(pin, original, source):
    if pin.read_text() != original:
        raise ValueError("Rex pin changed during validation; rerun update-rex")
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=pin.parent, delete=False) as handle:
            temporary = Path(handle.name)
            handle.write(json.dumps(source, indent=2) + "\n")
        temporary.chmod(pin.stat().st_mode & 0o777)
        temporary.replace(pin)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def update(root, check=False):
    pin = root / "pkgs/rex/source.json"
    original = pin.read_text()
    source = json.loads(original)
    current = VERSION.fullmatch(source["version"])
    if current is None:
        raise ValueError(f"Unrecognized pinned Rex version: {source['version']!r}")
    feed = run(
        "curl", "--fail", "--silent", "--show-error", "--location", "--compressed",
        "--proto", "=https", "--proto-redir", "=https",
        "--connect-timeout", "15", "--max-time", "60", FEED_URL,
    )
    version, url = latest_release(feed)
    latest = VERSION.fullmatch(version)
    if int(latest[2]) <= int(current[2]):
        print(f"Rex {source['version']} is already at or ahead of the feed's latest build.")
        return
    print(f"Rex: {source['version']} -> {version}", flush=True)
    if check:
        return
    prefetched = json.loads(run("nix", "store", "prefetch-file", "--json", url))
    updated = {**source, "version": version, "hash": prefetched["hash"]}
    with tempfile.TemporaryDirectory(prefix="update-rex-") as directory:
        package = build_candidate(root, updated, Path(directory))
        verify_package(package, version)
    write_pin(pin, original, updated)
    print(f"Updated {pin}; build and signature checks passed.")
    print("Review the pin, then run darwin-rebuild switch to apply it.")
    print("The running app and system generation have not changed.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", nargs="?", default=".", help="flake checkout (default: current directory)")
    parser.add_argument("--check", action="store_true", help="report available updates without changing files or building")
    args = parser.parse_args()
    try:
        if sys.platform != "darwin":
            raise ValueError("update-rex requires macOS for app signature verification")
        update(find_flake(args.directory), check=args.check)
    except (OSError, ValueError, KeyError, ET.ParseError, subprocess.CalledProcessError) as error:
        print(f"update-rex: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
