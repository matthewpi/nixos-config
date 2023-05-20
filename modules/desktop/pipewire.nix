{lib, ...}: {
  # Disable pulseaudio
  hardware.pulseaudio.enable = false;

  # Enable real-time kit
  security.rtkit.enable = lib.mkDefault true;

  # Enable pipewire
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa = {
      enable = lib.mkDefault true;
      support32Bit = lib.mkDefault true;
    };
    pulse.enable = lib.mkDefault true;
  };

  # TODO: this configuration is very specific to my audio setup,
  # maybe add config options or a way to tweak this easily?
  environment.etc."pipewire/99-custom.conf".text = ''
    context.properties = {
      default.clock.rate = 96000
      default.clock.allowed-rates = [44100 48000 96000]

      default.clock.min-quantum = 96
    }

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
        name = "libpipewire-module-protocol-native"
      }

      {
        name = "libpipewire-module-client-node"
      }

      {
        name = "libpipewire-module-adapter"
      }

      {
        name = "libpipewire-module-metadata"
      }

      {
        name = "libpipewire-module-protocol-pulse"
        args = {
          pulse.min.req = 96/96000
          pulse.min.quantum = 96/96000
          pulse.min.frag = 96/96000
          server.address = ["unix:native"]
        }
      }
    ]

    stream.properties = {
      node.latecy = 96/96000
      resample.quality = 1
    }
  '';

  # Enable sound
  sound.enable = lib.mkDefault true;
}
