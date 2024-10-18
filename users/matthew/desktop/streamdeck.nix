{
  config,
  isDesktop,
  ...
}: {
  systemd.user.services.streamdeck = lib.mkIf isDesktop {
    Unit = {
      Description = "Streamdeck";
      BindsTo = ["dev-streamdeck.device"];
      After = ["dev-streamdeck.device"];
      X-SwitchMethod = "keep-old"; # TODO: figure out if this is the best option.
      ConditionPathExists = [
        "/code/matthewpi/streamdeck-local/streamdeck"
        "/dev/streamdeck"
      ];
    };

    Service = {
      ExecStart = "/code/matthewpi/streamdeck-local/streamdeck"; # TODO: package
      KillSignal = "SIGINT";
      Restart = "on-failure";
      Slice = "background.slice";

      # Capabilities
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;

      # Filesystem
      # Access to /run/user/<uid> is required for DBus.
      BindPaths = ["/run/user"];
      BindReadOnlyPaths = [
        # Cache locations, usually for album art
        "${config.home.homeDirectory}/.cache/amberol"
        # Configuration location
        "${config.home.homeDirectory}/.config/streamdeck"
        # Allow access to the binary since it's not packaged by Nix.
        "/code/matthewpi/streamdeck-local"
      ];
      ProtectHome = "tmpfs";
      ProtectSystem = "strict";
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
      #SystemCallFilter = "@default"; # TODO

      # Networking
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];

      # Misc
      LockPersonality = true;
      ProtectHostname = true;
      RestrictRealtime = true;
      MemoryDenyWriteExecute = true;
      RestrictNamespaces = true;
      PrivateUsers = true;
      KeyringMode = "private";
      DevicePolicy = "closed";
      DeviceAllow = "/dev/streamdeck";
    };

    Install.WantedBy = ["hyprland-session.target"];
  };
}
