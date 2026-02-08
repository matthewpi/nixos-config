{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  agsPackages = inputs.ags.packages."${pkgs.stdenv.hostPlatform.system}";

  shell = pkgs.stdenv.mkDerivation {
    pname = "shell";
    version = "0.0.1";
    src = builtins.filterSource (p: _type: p != "default.nix") ./.;

    nativeBuildInputs = [
      agsPackages.default
      pkgs.gobject-introspection
      pkgs.wrapGAppsHook4
    ];

    buildInputs = [
      pkgs.glib
      pkgs.gjs
      pkgs.libadwaita

      agsPackages.astal4
      agsPackages.io

      agsPackages.apps
      agsPackages.battery
      agsPackages.bluetooth
      agsPackages.hyprland
      agsPackages.mpris
      agsPackages.notifd
      agsPackages.powerprofiles
      agsPackages.tray
      agsPackages.wireplumber
    ];

    buildPhase = ''
      ags bundle app.ts shell --gtk 4
    '';

    installPhase = ''
      install -Dm755 -t "$out"/bin shell
    '';

    meta.mainProgram = "shell";
  };
in {
  # Link the config to `.config/ags`.
  xdg.configFile."ags".source = shell.src;

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
      Type = "notify";
      NotifyAccess = "all";

      ExecStart = lib.getExe shell;

      Slice = "session.slice";

      Restart = "always";
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
