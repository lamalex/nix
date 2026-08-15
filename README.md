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
