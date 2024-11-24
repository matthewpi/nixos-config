{
  # This ensures that the LVM partitions can actually be used.
  boot.initrd.services.lvm.enable = true;

  fileSystems = {
    "/persist".neededForBoot = true;
    "/persist/home".neededForBoot = true;
    "/var/log".neededForBoot = true;
  };

  # nvme0n1 is a 4 TB NVMe SSD
  disko.devices.disk.nvme0n1 = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          # 1 GB per 1 TB seems reasonable.
          #
          # This is also useful since we may have a Windows Boot Loader or
          # other things here, so having some extra space will be very useful.
          size = "4G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["defaults" "umask=0077"];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            passwordFile = "/tmp/luks.key";
            settings = {
              allowDiscards = true;
              bypassWorkqueues = true;
            };
            content = let
              defaultOptions = [
                # Disable access times on files.
                "noatime"
                # TODO: document
                "nodev"
                # Prevent SUID binaries from being used.
                #
                # Any binaries that need SUID privileges will be created by Nix
                # and put into `/run/wrappers/bin` which has SUID permissions.
                "nosuid"
                # Use asynchronous discard (https://wiki.archlinux.org/title/Btrfs#SSD_TRIM)
                "discard=async"
              ];
            in {
              type = "btrfs";
              # extraArgs = ["-f"]; # Override existing partition
              # mountOptions = ["defaults" "lazytime"];

              postCreateHook = ''
                MNTPOINT="$(mktemp -d)"
                SRCMNT='/dev/mapper/crypted'

                mount -t btrfs -o 'compress=zstd,noatime,nodev,noexec,nosuid,discard=async' "$SRCMNT" "$MNTPOINT"
                trap 'umount $MNTPOINT; rmdir $MNTPOINT' EXIT

                btrfs subvolume snapshot -r "$MNTPOINT"/rootfs "$MNTPOINT"/rootfs-blank
              '';

              subvolumes = {
                "/rootfs" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noexec"] ++ defaultOptions;
                };

                "/tmp" = {
                  mountpoint = "/tmp";
                  # Needs `exec` for some Nix builds, should re-visit the
                  # possibility of `noexec` for `/tmp` by either fixing Nix
                  # builds or by getting Nix to use a different `/tmp` directory
                  # that has `exec` enabled.
                  mountOptions = ["compress=zstd"] ++ defaultOptions;
                };

                "/nix" = {
                  mountpoint = "/nix";
                  # Needs `exec`, it's the nix store. Y'know where all the
                  # binaries live.
                  #
                  # Previously I didn't run compression on the Nix store, but
                  # Nix actually has optimizations when FS compression is
                  # enabled, so we use it.
                  mountOptions = ["compress=zstd"] ++ defaultOptions;
                };

                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = ["compress=no" "noexec"] ++ defaultOptions;
                };

                "/persist/home" = {
                  mountpoint = "/persist/home";
                  mountOptions = ["compress=no"] ++ defaultOptions;
                };

                # Usually this would be done via impermanence, but logs are
                # very important since they can prevent the system from booting
                # or working correctly.
                "/var/log" = {
                  mountpoint = "/var/log";
                  mountOptions = ["compress=zstd" "noexec"] ++ defaultOptions;
                };

                # This is going to be where all my code lives on this machine.
                #
                # While it would make more sense for this to go under `/home`,
                # I'd much rather put it in it's own subvolume outside of my
                # home directory where I can snapshot it independently.
                "/code" = {
                  mountpoint = "/code";
                  mountOptions = ["compress=zstd"] ++ defaultOptions;
                };
              };
            };
          };
        };
      };
    };
  };
}
