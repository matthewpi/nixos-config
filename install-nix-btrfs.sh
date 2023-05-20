#!/run/current-system/sw/bin/bash

set -e

# Install NixOS
nixos-install --flake .\#desktop

# home-manager runs the user units as the user itself, so we need to create the home directory
# before we can run the user units.
mkdir -p /mnt/persist/home/matthew
chmod 700 /mnt/persist/home/matthew
# TODO: find a way to get the uid and gid from the user.
chown 1000:100 /mnt/persist/home/matthew

# Enroll the secure boot keys.
#
# TODO: detect if secureboot is in setup mode and automatically run this.
# Or we can always just print the command to the user.
#nix run --extra-experimental-features nix-command --extra-experimental-features flakes nixpkgs#sbctl -- enroll-keys --microsoft
