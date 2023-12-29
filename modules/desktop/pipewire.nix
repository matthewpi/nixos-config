{
  config,
  lib,
  ...
}: let
  rate = 96000;
  # TODO: add to config
  #rates = [44100 48000 96000];
  # Disabled due to causing audio cracks, re-visit once we figure out a solution.
  quantum = 240; # (rate / 1000) * 2.5
in {
  # Disable pulseaudio
  hardware.pulseaudio.enable = false;

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
  };

  # Low-latency configuraiton
  environment.etc."pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
    context.properties = {
      default.clock.rate = ${toString rate}
      default.clock.allowed-rates = [44100 48000 96000]

      #default.clock.min-quantum = ${toString quantum}
      #default.clock.max-quantum = ${toString quantum}
      #default.clock.quantum = ${toString quantum}
    }
  '';
  environment.etc."pipewire/pipewire-pulse.d/92-low-latency.conf".text = ''
    context.modules = [
      {
        name = "libpipewire-module-rtkit"
        args = {
          nice.level = -15
          rt.prio = 88
          rt.time.soft = 200000
          rt.time.hard = 200000
        }
        flags = ["ifexists" "nofail"]
      }
      {
        name = "libpipewire-module-protocol-pulse"
        args = {
          #pulse.min.req = ${toString quantum}/${toString rate}
          #pulse.min.quantum = ${toString quantum}/${toString rate}
          #pulse.min.frag = ${toString quantum}/${toString rate}
          server.address = ["unix:native"]
        }
      }
    ]

    #stream.properties = {
    #  node.latency = ${toString quantum}/${toString rate}
    #  resample.quality = 1
    #}
  '';

  # Enable sound
  sound.enable = lib.mkDefault true;
}
