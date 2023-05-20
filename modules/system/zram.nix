{pkgs, ...}: {
  environment.etc."systemd/zram-generator.conf".text = ''
    [zram0]
    zram-size = min(ram / 4, 16384)
    compression-algorithm = zstd
  '';

  systemd.packages = [pkgs.zram-generator];
  systemd.services."systemd-zram-setup@".path = [pkgs.util-linux];
}
