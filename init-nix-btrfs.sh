#!/run/current-system/sw/bin/bash

set -e

# This script configures a btrfs filesystem for use with NixOS.

DEVICE="/dev/vda"

BOOT_SIZE="512MB"
CONFIGURE_SWAP="false"
SWAP_SIZE="8GB"

BOOT_PARTITION="$DEVICE"1
ROOT_PARTITION="$DEVICE"2
SWAP_PARTITION="$DEVICE"3

# Create a GPT partition table.
parted "$DEVICE" -- mklabel gpt

# Create the ESP (EFI System Partition).
parted "$DEVICE" -- mkpart ESP fat32 1MB "$BOOT_SIZE"
parted "$DEVICE" -- set 1 esp on

# Create the root partition, and optionally a swap partition.
if [[ $CONFIGURE_SWAP == "true" ]]; then
	parted "$DEVICE" -- mkpart primary "$BOOT_SIZE" "-$SWAP_SIZE"
	parted "$DEVICE" -- mkpart primary linux-swap "-$SWAP_SIZE" 100%
else
	parted "$DEVICE" -- mkpart primary "$BOOT_SIZE" 100%
fi

# Format the ESP.
mkfs.fat -F 32 -n boot "$BOOT_PARTITION"

# Setup the swap partition.
if [[ $CONFIGURE_SWAP == "true" ]]; then
	mkswap -L swap "$SWAP_PARTITION"
	swapon "$SWAP_PARTITION"
fi

# Configure LUKS encryption for the root partition.
cryptsetup luksFormat --type luks2 "$ROOT_PARTITION"

# Label the LUKS container.
cryptsetup config --label crypted "$ROOT_PARTITION"

# Mount the LUKS container, and configure the root filesystem.
cryptsetup luksOpen --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent "$ROOT_PARTITION" root
mkfs.btrfs -L root /dev/mapper/root

# Mount the root filesystem.
mount -t btrfs -o compress=no,noatime,noexec,discard=async /dev/mapper/root /mnt

# Configure the root filesystem subvolumes.
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/tmp
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/log

# Snapshot the root subvolume, this is used as a rollback point to ensure a clean state,
# for anything that should not be persisted across reboots.
btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

# Unmount the root filesystem.
umount /mnt

# Remount the root filesystem with the subvolumes mounted.
mount -o subvol=root,compress=zstd,noatime,noexec,discard=async /dev/mapper/root /mnt

mkdir /mnt/tmp
mount -o subvol=tmp,compress=zstd,noatime,discard=async /dev/mapper/root /mnt/tmp

mkdir /mnt/nix
mount -o subvol=nix,compress=zstd,noatime,discard=async /dev/mapper/root /mnt/nix

mkdir /mnt/persist
mount -o subvol=persist,compress=no,noatime,noexec,discard=async /dev/mapper/root /mnt/persist

mkdir /mnt/persist/home
mount -o subvol=home,compress=no,noatime,noexec,discard=async /dev/mapper/root /mnt/persist/home

mkdir -p /mnt/var/log
mount -o subvol=log,compress=zstd,noatime,noexec,discard=async /dev/mapper/root /mnt/var/log

# Mount the boot partition.
mkdir /mnt/boot
mount "$BOOT_PARTITION" /mnt/boot

# Generate secure boot keys.
nix run --extra-experimental-features nix-command --extra-experimental-features flakes nixpkgs#sbctl create-keys

# Persist the secure boot keys.
mkdir /mnt/persist/etc
cp -r /etc/secureboot /mnt/persist/etc/

# Generate the NixOS configuration.
nixos-generate-config --root /mnt
