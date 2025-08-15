{
  config,
  lib,
  pkgs,
  ...
}: {
  systemd.user.services.tailscale-systray = {
    Unit = {
      Description = "Tailscale Systray";
      PartOf = [config.wayland.systemd.target];
      After = [config.wayland.systemd.target];
    };

    Install.WantedBy = [config.wayland.systemd.target];

    Service = {
      Type = "exec";
      ExecStart = lib.getExe' pkgs.tailscale.systray "tailscale-systray";
      KillSignal = "SIGINT";
      Restart = "no";
      Slice = "background.slice";

      # Capabilities
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;

      # Filesystem
      BindPaths = [
        # Access to /run/user/<uid> is required for DBus.
        "/run/user"
        # Access to /run/tailscale/tailscale.sock is required.
        "/run/tailscale"
      ];
      ProtectHome = "tmpfs"; # Required to allow access to `/run/user/<uid>`.
      ProtectSystem = "strict";
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
      RestrictAddressFamilies = ["AF_UNIX"];

      # Misc
      LockPersonality = true;
      ProtectHostname = true;
      RestrictRealtime = true;
      MemoryDenyWriteExecute = true;
      RestrictNamespaces = true;
      PrivateUsers = true;
      KeyringMode = "private";
      DevicePolicy = "closed";
    };
  };
}
