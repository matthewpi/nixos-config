#!/run/current-system/sw/bin/bash

set -e

# Install NixOS
nixos-install --flake .\#kubernetes

# home-manager runs the user units as the user itself, so we need to create the home directory
# before we can run the user units.
mkdir -p /mnt/persist/home/matthew
chmod 700 /mnt/persist/home/matthew
# TODO: find a way to get the uid and gid from the user.
chown 1000:100 /mnt/persist/home/matthew

# TODO: do we need to make any other directories?

# Enroll the secure boot keys.
#
# TODO: there is a high likelihood that this will fail unless secureboot is in setup mode.
#nix run --extra-experimental-features nix-command --extra-experimental-features flakes nixpkgs#sbctl -- enroll-keys --microsoft
