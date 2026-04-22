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

4. Clone this repo into `~/.config/nix` and enter it:

   ```sh
   git clone <repo-url> ~/.config/nix
   cd ~/.config/nix
   ```

5. Apply the host configuration:

   ```sh
   sudo nix run --inputs-from . nix-darwin#darwin-rebuild -- switch --flake path:$PWD#<host>
   ```

Use one of the currently-defined hosts for `<host>`:

- `ferenginar`
- `andoria`

After the first switch, run the same `darwin-rebuild` command from the repo root whenever you want to apply changes.
