{inputs, ...}: {
  flake.nixosModules.determinate = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Stronger than mkDefault (1000), weaker than mkForce (50) and the "default override priority"
    # (100).
    mkPreferable = lib.mkOverride 750;

    # Stronger than the "default override priority", as the upstream module uses that, and weaker than mkForce (50).
    mkMorePreferable = lib.mkOverride 75;

    determinate-nixd =
      pkgs.runCommand "determinate-nixd" rec {
        pname = "determinate-nixd";
        version = "3.6.6";
        name = "${pname}-${version}";
        meta.mainProgram = "determinate-nixd";
      } ''
        mkdir -p "$out"/bin
        cp ${inputs."determinate-nixd-${pkgs.stdenv.system}"} "$out"/bin/determinate-nixd
        chmod +x "$out"/bin/determinate-nixd
        "$out"/bin/determinate-nixd --help
      '';

    nix = inputs.nix.packages.${pkgs.stdenv.system}.nix.override (oldAttrs: {
      # Disable nix-functional-tests.
      nix-functional-tests = oldAttrs.nix-functional-tests.overrideAttrs {
        doCheck = false;
      };
    });
  in {
    nix.package = nix;
    environment.systemPackages = [determinate-nixd];

    # NOTE(cole-h): Move the generated nix.conf to /etc/nix/nix.custom.conf, which is included from
    # the Determinate Nixd-managed /etc/nix/nix.conf.
    environment.etc."nix/nix.conf".target = "nix/nix.custom.conf";

    systemd.services.nix-daemon.serviceConfig = {
      ExecStart = [
        ""
        "@${lib.getExe determinate-nixd} determinate-nixd --nix-bin ${config.nix.package}/bin daemon"
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

      unitConfig = {
        RequiresMountsFor = ["/nix/store" "/nix/var/determinate"];
      };

      socketConfig = {
        Service = "nix-daemon.service";
        FileDescriptorName = "determinate-nixd.socket";
        ListenStream = "/nix/var/determinate/determinate-nixd.socket";
        DirectoryMode = "0755";
      };
    };

    # Enable lazy-trees by default.
    nix.settings.lazy-trees = lib.mkDefault true;
  };
}
