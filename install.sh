#!/usr/bin/env bash

set -euo pipefail

name='desktop'
username='matthew'

FORMAT_SCRIPT=$(nix build --no-link --print-out-paths '.#nixosConfigurations.'"$name"'.config.system.build.formatScript')
MOUNT_SCRIPT=$(nix build --no-link --print-out-paths '.#nixosConfigurations.'"$name"'.config.system.build.mountScript')

sudo "${FORMAT_SCRIPT}"
sudo "${MOUNT_SCRIPT}"

sudo mkdir -p /mnt/persist/etc/ssh
sudo chmod 755 /mnt/persist/etc/ssh
echo 'Generating SSH host keys'
sudo ssh-keygen -t ed25519 -N '' -C '' -f /mnt/persist/etc/ssh/ssh_host_ed25519_key
sudo cat /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub
sudo ssh-keygen -t ecdsa -b 256 -N '' -C '' -f /mnt/persist/etc/ssh/ssh_host_ecdsa_key
sudo cat /mnt/persist/etc/ssh/ssh_host_ecdsa_key.pub
sudo ssh-keygen -t rsa -b 4096 -N '' -C '' -f /mnt/persist/etc/ssh/ssh_host_rsa_key
sudo cat /mnt/persist/etc/ssh/ssh_host_rsa_key.pub

# Create a home directory for the main user.
#
# This avoids an issue where their directory somehow doesn't exist or gets
# created with root as the owner, potentially breaking the user.
sudo mkdir -p /mnt/persist/home/"$username"
sudo chmod 700 /mnt/persist/home/"$username"
sudo chown 1000:100 /mnt/persist/home/"$username"

# Generate new secureboot keys to sign the OS with.
# nix run 'nixpkgs#sbctl' create-keys

# Persist the secure boot keys.
sudo mkdir -p /mnt/persist/etc
sudo cp -r /etc/secureboot /mnt/persist/etc/

echo 'Building system configuration...'
system=$(nix build --no-link --print-out-paths '.#nixosConfigurations.'"$name"'.config.system.build.toplevel')
echo 'Built system configuration: '"$system"

echo 'Copying system configuration...'
sudo nix copy --no-check-sigs --to '/mnt' "$system"
echo 'Copied system configuration...'

echo 'Activating system configuration...'
sudo mkdir -p /mnt/etc
sudo touch /mnt/etc/NIXOS /mnt/persist/etc/NIXOS
sudo nix-env --store /mnt --profile /mnt/nix/var/nix/profiles/system --set "$system"
sudo NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot
echo 'Activated system configuration'
