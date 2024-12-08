{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [gauntlet];

  systemd.user.services.gauntlet = {
    Unit.Description = "Gauntlet";
    Install.WantedBy = ["hyprland-session.target"];

    Service = {
      Type = "exec";
      ExecStart = "${lib.getExe pkgs.gauntlet} --minimized";
      KillSignal = "SIGINT";
      Restart = "no";
      Slice = "background.slice";

      # Capabilities
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;

      # Filesystem
      # TODO: figure out what Gauntlet needs access to.
      # BindPaths = [
      #   # Access to /run/user/<uid> is required for DBus.
      #   "/run/user"
      # ];
      # BindReadOnlyPaths = ["${config.home.homeDirectory}/.local/share/gauntlet"];
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
      # SystemCallFilter = "@system-service"; # TODO

      # Networking
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];

      # Misc
      LockPersonality = true;
      ProtectHostname = true;
      RestrictRealtime = true;
      MemoryDenyWriteExecute = false; # We cannot set this to true due to the way Gauntlet works.
      RestrictNamespaces = true;
      PrivateUsers = true;
      # KeyringMode = "private";
      DevicePolicy = "closed";
    };
  };
}
