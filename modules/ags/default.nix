{
  config,
  lib,
  outputs,
  pkgs,
  ...
}: let
  ags = outputs.packages."${pkgs.stdenv.hostPlatform.system}".ags;
in {
  # Install the AGS CLI.
  home.packages = [ags];

  # Link the config to `.config/ags`.
  xdg.configFile."ags".source = builtins.filterSource (path: _type: path != "default.nix") ./.;

  # Configure a systemd user service for AGS.
  systemd.user.services.ags = {
    Unit = {
      Description = "AGS";
      Documentation = "https://github.com/Aylur/ags";
      After = ["graphical-session-pre.target"];
      Before = ["xdg-desktop-autostart.target"];
      PartOf = [config.wayland.systemd.target];
    };

    Install.WantedBy = [config.wayland.systemd.target];

    Service = {
      ExecStart = "${lib.getExe ags} run --gtk 4";
      # Wait 1 second after AGS starts before continuing.
      #
      # This helps avoid a timing issue where system tray applications autostart
      # before AGS is actually ready.
      #
      # TODO: does pre-building/bundling resolve this? We also may want to
      # consider adding sdnotify into AGS instead just to be 100% sure we don't
      # encounter any timing issues.
      ExecStartPost = "${lib.getExe' pkgs.coreutils "sleep"} 1";
      Slice = "session.slice";

      Restart = "on-failure";
      KillMode = "mixed";

      # Capabilities
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;

      # Filesystem
      # TODO: figure out how to protect home and system without breaking themes and styles.
      # BindPaths = [
      #   # Required to access Hyprland IPC
      #   "/run/user/1000/hypr"
      # ];
      # BindReadOnlyPaths = [
      #   "/etc/profiles/per-user/matthew"
      #   "${config.home.homeDirectory}/.config/ags"
      # ];
      # ProtectHome = "tmpfs";
      # ProtectSystem = "strict";
      PrivateDevices = false;
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
  };
}
