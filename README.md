# nix

Personal macOS configuration built with `nix-darwin`, `home-manager`, and `nix-homebrew`.

## Bootstrapping

1. Install Apple's command line tools so `git` is available:

   ```sh
   xcode-select --install
   ```

2. Install Determinate Nix:

   https://install.determinate.systems/determinate-pkg/stable/Universal

3. Generate an SSH key and add the public key as a deploy key to the `nex` repo:

   ```sh
   mkdir -p ~/.ssh
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_nex -C "$(whoami)@$(scutil --get LocalHostName)-nex"
   pbcopy < ~/.ssh/id_ed25519_nex.pub
   ```

4. Clone this repo into `~/Code/nix` and enter it:

   ```sh
   git clone <repo-url> ~/Code/nix
   cd ~/Code/nix
   ```

5. Apply the host configuration:

   ```sh
   sudo nix run --inputs-from . nix-darwin#darwin-rebuild -- switch --flake path:$PWD#<host>
   ```

Use one of the currently-defined hosts for `<host>`:

- `ferenginar`
- `andoria`
- `rubiconiii`

After the first switch, run the same `darwin-rebuild` command from the repo root whenever you want to apply changes.

## Pakled NixOS installer

Build the x86_64 installer ISO through Determinate Nix's native Linux builder:

```sh
nix build path:$PWD#packages.x86_64-linux.pakled-iso
```

The ISO is written under `result/iso/`. Boot it on Pakled, connect Ethernet,
and run:

```sh
install-pakled
```

The command refuses to erase a USB-backed `/dev/sda` and requires explicit
confirmation before repartitioning `/dev/sda`. It installs the console-only
`Pakled` configuration, copies this flake to `~/Code/nix`, and prompts for the
`alexlauni` console password. SSH public-key login is preconfigured.

After the first boot, join Pakled to the tailnet interactively:

```sh
sudo tailscale up
```

### Pakled GitHub Actions runner and binary cache

Pakled declares one ephemeral organization runner in the `yaffle-build-farm`
runner group. Before activating it, create that group in the Yaffle GitHub
organization and restrict it to the intended private repositories and workflow
files. Then provision a fine-grained PAT with organization self-hosted runner
read/write permission directly on Pakled:

```sh
sudo install -d -m 0700 /var/lib/github-runner
printf '%s' "$GITHUB_RUNNER_PAT" | sudo tee /var/lib/github-runner/yaffle.token >/dev/null
sudo chmod 0600 /var/lib/github-runner/yaffle.token
```

The token must not contain a trailing newline. It is intentionally absent from
the flake and Nix store.

Attic is colocated on Pakled and exposed only through the Tailscale interface.
Generate its JWT signing secret on Pakled, outside the Nix store:

```sh
sudo install -d -m 0700 /var/lib/atticd-secret
secret="$(openssl genrsa -traditional 4096 | base64 -w0)"
printf 'ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=%s\n' "$secret" \
  | sudo tee /var/lib/atticd-secret/atticd.env >/dev/null
sudo chmod 0600 /var/lib/atticd-secret/atticd.env
unset secret
```

After applying the configuration, use `atticd-atticadm` on Pakled to create the
cache and separate read/write tokens. Pull-request runners should receive only
read access; cache write tokens belong only in trusted main-branch workflows.

## Adding a new host

Hosts are auto-discovered from `hosts/darwin/` — the directory name becomes the
machine's host name, so there is nothing to register in `flake.nix`.

1. Create `hosts/darwin/<name>/default.nix` that imports a profile:

   ```nix
   {
     imports = [ ../../common/personal.nix ]; # or work.nix
   }
   ```

2. Generate an SSH key for the host as a new SSH Key item in 1Password,
   add the public key to `hostKeys` in `home/alexlauni.nix` (the build fails
   without it), and upload it to GitHub as both an authentication key and a
   signing key.

3. Track it in git (flakes only see tracked files):

   ```sh
   git add hosts/darwin/<name>
   ```

4. Apply it:

   ```sh
   sudo nix run --inputs-from . nix-darwin#darwin-rebuild -- switch --flake path:$PWD#<name>
   ```
