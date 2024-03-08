{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable ags.
  programs.ags = {
    enable = true;
    configDir = ./hyprland;
  };

  # Used by AGS.
  #
  # Ideally we wouldn't install these globally and instead would add it to the path of the AGS
  # service, but overwriting the PATH of the service causes issues when listing applications
  # in the app launcher.
  home.packages = with pkgs; [bun sass];

  # Configure a systemd user service for AGS.
  systemd.user.services.ags = {
    Unit = {
      Description = "AGS";
    };

    Service = {
      ExecStart = lib.getExe' config.programs.ags.package "ags";
      Slice = "session.slice";

      # Capabilities
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;

      # Filesystem
      # TODO: figure out how to protect home and system without breaking themes and styles.
      BindPaths = [
        # Required to access Hyprland IPC
        "/tmp/hypr"
        # "/run/user"
      ];
      # BindReadOnlyPaths = [
      #   "/etc/profiles/per-user/matthew"
      #   "${config.home.homeDirectory}/.config/ags"
      # ];
      # ProtectHome = "tmpfs";
      # ProtectSystem = "strict";
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = true;
      ProtectControlGroups = true;
      ProtectProc = "noaccess";
      ProcSubset = "pid";
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      UMask = "0077";

      # Kernel
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service";

      # Networking
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];

      # Misc
      LockPersonality = true;
      ProtectHostname = true;
      RestrictRealtime = true;
      MemoryDenyWriteExecute = false; # We cannot set this to true due to the way AGS and GJS work.
      RestrictNamespaces = true;
      PrivateUsers = true;
      DevicePolicy = "closed";
    };

    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };
}
