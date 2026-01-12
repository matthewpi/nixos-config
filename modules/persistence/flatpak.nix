{lib, ...}: {
  config = {
    # TODO: add options to impermanence to allow setting additional `options`.
    #
    # We need this entire thing since `systemd.mounts` is an array and not an
    # attrset just so we can add the `exec` option.
    systemd.mounts = [
      {
        wantedBy = ["local-fs.target"];
        before = ["local-fs.target"];
        where = "/var/lib/flatpak";
        what = "/persist/var/lib/flatpak";
        unitConfig.DefaultDependencies = false;
        type = "none";
        options = lib.concatStringsSep "," ["bind" "exec" "x-gvfs-hide"];
      }
    ];
  };
}
