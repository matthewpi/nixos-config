{
  config,
  lib,
  pkgs,
  ...
}: let
  rate = 96000;
  rates = [44100 48000 96000];
  #quantum = 240; #(rate / 1000) * 2.5;
  #quantumRate = "96/48000";

  json = pkgs.formats.json {};
in {
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

  # Low-latency configuration
  environment.etc."pipewire/pipewire.conf.d/99-lowlatency.conf".source = json.generate "99-lowlatency.conf" {
    context.properties.default.clock = {
      rate = toString rate;
      allowed-rates = rates;
      # min-quantum = toString quantum;
      # max-quantum = toString quantum;
      # quantum = toString quantum;
    };
  };

  environment.etc."pipewire/pipewire-pulse.d/99-lowlatency.conf".source = json.generate "99-lowlatency.conf" {
    context.modules = [
      {
        name = "libpipewire-module-rtkit";
        args = {
          nice.level = -15;
          rt.prio = 88;
          rt.time.soft = 200000;
          rt.time.hard = 200000;
        };
        flags = ["ifexists" "nofail"];
      }
      {
        name = "libpipewire-module-protocol-pulse";
        args = {
          #pulse.min.req = quantumRate;
          #pulse.min.quantum = quantumRate;
          #pulse.min.frag = quantumRate;
          server.address = ["unix:native"];
        };
      }
    ];

    stream.properties = {
      #node.latency = quantumRate;
      resample.quality = 1;
    };
  };

  # Enable sound
  sound.enable = lib.mkDefault true;
}
