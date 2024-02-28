{
  config,
  lib,
  ...
}: {
  # Disable pulseaudio
  hardware.pulseaudio.enable = lib.mkForce false;

  # Enable real-time kit
  security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;
  # https://wiki.archlinux.org/title/PipeWire#Missing_realtime_priority/crackling_under_load_after_suspend
  # systemd.services.rtkit-daemon.serviceConfig.ExecStart = "${pkgs.rtkit}/libexec/rtkit-daemon --no-canary";

  # Enable pipewire
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa = {
      enable = lib.mkDefault true;
      support32Bit = lib.mkDefault true;
    };
    pulse.enable = lib.mkDefault true;
  };

  # Enable sound
  sound.enable = lib.mkDefault true;
}
