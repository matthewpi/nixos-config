{
  flake.nixosModules.determinate = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.determinate;

    # Stronger than mkDefault (1000), weaker than mkForce (50) and the "default override priority"
    # (100).
    mkPreferable = lib.mkOverride 750;

    # Stronger than the "default override priority", as the upstream module uses that, and weaker than mkForce (50).
    mkMorePreferable = lib.mkOverride 75;

    determinatePackages = {
      determinate-nix = pkgs.callPackage ./determinate-nix.nix {};
      determinate-nixd = pkgs.callPackage ./determinate-nixd.nix {};
    };
  in {
    options.determinate = {
      enable = lib.mkEnableOption "Determinate Nix" // {default = true;};
      package = lib.mkPackageOption determinatePackages "determinate-nix" {};
      daemonPackage = lib.mkPackageOption determinatePackages "determinate-nixd" {};
    };

    config = lib.mkIf cfg.enable {
      # Move the generated nix.conf to /etc/nix/nix.custom.conf, which is
      # included from the Determinate Nixd-managed /etc/nix/nix.conf.
      environment.etc."nix/nix.conf".target = "nix/nix.custom.conf";

      # Use the determinate-nix packages.
      nix.package = cfg.package;
      environment.systemPackages = [cfg.daemonPackage];

      systemd.services.nix-daemon.serviceConfig = {
        ExecStart = [
          ""
          "@${lib.getExe cfg.daemonPackage} determinate-nixd --nix-bin ${config.nix.package}/bin daemon"
        ];
        KillMode = mkPreferable "process";
        LimitNOFILE = mkMorePreferable 1048576;
        LimitSTACK = mkPreferable "64M";
        TasksMax = mkPreferable 1048576;
      };

      systemd.sockets.nix-daemon.socketConfig.FileDescriptorName = "nix-daemon.socket";
      systemd.sockets.determinate-nixd = {
        description = "Determinate Nixd Daemon Socket";
        wantedBy = ["sockets.target"];
        before = ["multi-user.target"];
        unitConfig.RequiresMountsFor = ["/nix/store" "/nix/var/determinate"];
        socketConfig = {
          Service = "nix-daemon.service";
          FileDescriptorName = "determinate-nixd.socket";
          ListenStream = "/nix/var/determinate/determinate-nixd.socket";
          DirectoryMode = "0755";
        };
      };
    };
  };
}
