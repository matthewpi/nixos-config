{inputs, ...}: {
  flake.nixosModules.persistence = {
    imports = [
      inputs.impermanence.nixosModules.impermanence

      ./bluetooth.nix
      ./chrony.nix
      ./colord.nix
      ./flatpak.nix
      ./fprint.nix
      ./fwupd.nix
      ./gnome.nix
      ./libvirtd.nix
      ./networkmanager.nix
      ./openssh.nix
      ./plymouth.nix
      ./podman.nix
      ./tailscale.nix
      ./wireless.nix
    ];

    # Setup a service that will automatically rollback the root subvolume to a fresh state.
    boot.initrd.systemd.services.rollback = let
      luksName = "crypted";
      rootSubvolume = "rootfs";
    in {
      description = "Rollback BTRFS root subvolume to a fresh state";
      wantedBy = ["initrd.target"];
      before = ["sysroot.mount"];
      after = ["systemd-cryptsetup@${luksName}.service"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";

      script = ''
        mkdir -p /btrfs
        mount -t btrfs -o compress=zstd,noatime,nodev,noexec,nosuid,discard=async /dev/mapper/${luksName} /btrfs

        echo 'Cleaning subvolumes...'
        btrfs subvolume list -o /btrfs/${rootSubvolume} | cut -f9 -d ' ' |
          while read subvolume; do
            echo 'Deleting /'"$subvolume"' subvolume...'
            btrfs subvolume delete /btrfs/"$subvolume"
          done &&
          echo 'Deleting /${rootSubvolume} subvolume...' &&
          btrfs subvolume delete /btrfs/${rootSubvolume}

        echo 'Restoring blank /${rootSubvolume} subvolume...'
        btrfs subvolume snapshot /btrfs/${rootSubvolume}-blank /btrfs/${rootSubvolume}

        umount /btrfs
        rm -d /btrfs
      '';
    };

    # Disable sudo lectures, as they will be shown after every reboot otherwise.
    security.sudo.extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';

    # Persistence
    environment.persistence."/persist" = {
      directories = [
        "/etc/nixos"
        {
          directory = "/etc/secureboot";
          mode = "0700";
        }

        "/var/lib/nixos"
        {
          directory = "/var/lib/private";
          mode = "0700";
        }

        {
          directory = "/var/cache/restic-backups-matthew-code";
          mode = "0700";
          user = "matthew";
          group = "users";
        }
        {
          directory = "/var/cache/regreet";
          mode = "0750";
          user = "greeter";
          group = "greeter";
        }
        {
          directory = "/var/cache/tailscale";
          mode = "0750";
        }
        {
          directory = "/var/cache/private";
          mode = "0700";
        }

        {
          directory = "/root";
          mode = "0700";
        }
      ];

      files = [
        "/etc/machine-id"
        "/var/lib/power-profiles-daemon/state.ini"
      ];

      hideMounts = true;
    };
  };
}
