{
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  installPakled = pkgs.writeShellApplication {
    name = "install-pakled";
    runtimeInputs = [
      inputs.disko.packages.x86_64-linux.disko
      pkgs.coreutils
      pkgs.nixos-install-tools
      pkgs.util-linux
    ];
    text = ''
      if [[ "$EUID" -ne 0 ]]; then
        exec sudo "$0" "$@"
      fi

      disk=/dev/sda
      if [[ ! -b "$disk" ]]; then
        echo "$disk does not exist; refusing to install." >&2
        exit 1
      fi

      if [[ "$(lsblk -dn -o TRAN "$disk" | tr -d ' ')" == "usb" ]]; then
        echo "$disk is a USB device; refusing to erase the installer." >&2
        exit 1
      fi

      echo "This will permanently erase $disk and install Pakled."
      read -r -p "Type 'erase /dev/sda' to continue: " confirmation
      if [[ "$confirmation" != "erase /dev/sda" ]]; then
        echo "Installation cancelled."
        exit 1
      fi

      disko --mode disko --flake /etc/pakled#Pakled
      nixos-install --flake /etc/pakled#Pakled --no-root-passwd

      install -d -m 0755 /mnt/home/alexlauni/Code/nix
      cp -R /etc/pakled/. /mnt/home/alexlauni/Code/nix/
      chmod -R u+w /mnt/home/alexlauni/Code/nix
      chown -R 1000:users /mnt/home/alexlauni/Code

      echo "Set alexlauni's console password. SSH key login is already configured."
      nixos-enter --root /mnt -c 'passwd alexlauni'

      echo "Pakled is installed. Remove the USB drive, then reboot."
    '';
  };
in
{
  # Work around nixpkgs#550124 when building Linux initrds on macOS.
  boot.initrd.systemd.contents."/etc/terminfo/l/linux".source =
    lib.mkForce "${pkgs.ncurses}/share/terminfo/l~nix~case~hack~1/linux";

  networking.networkmanager.enable = true;
  networking.wireless.enable = pkgs.lib.mkForce false;

  environment = {
    etc."pakled".source = self.outPath;
    systemPackages = [ installPakled ];
  };

  isoImage.volumeID = "PAKLED";
}
