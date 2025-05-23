{
  config,
  lib,
  ...
}: {
  # Disable pulseaudio
  services.pulseaudio.enable = lib.mkForce false;

  # Enable real-time kit
  security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;

  # Enable pipewire
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa = {
      enable = lib.mkDefault true;
      support32Bit = lib.mkDefault true;
    };
    pulse.enable = lib.mkDefault true;

    # Configure low-latency quantum values for pipewire.
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        # "default.clock.rate" = 96000;
        "default.clock.quantum" = 512;
        "default.clock.min-quantum" = 512;
        "default.clock.max-quantum" = 512;
      };
    };
  };

  services.udev.extraRules = ''
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "soft";
      value = "99999";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "524288";
    }
  ];
}
