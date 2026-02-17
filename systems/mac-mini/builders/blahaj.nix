let
  sshAlias = "builder-blahaj";
  hostName = "blahaj.blahaj.systems";

  sshUser = "builder";
  sshKey = "/etc/nix/builder_ed25519";

  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2GQbheOCOd7QjlTCFLC2ZJzImc0I14l8cj5fAsS+aK";
  publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUoyR1FiaGVPQ09kN1FqbFRDRkxDMlpKekltYzBJMTRsOGNqNWZBc1MrYUs=";

  machine = system: {
    hostName = sshAlias;
    inherit sshUser sshKey publicHostKey system;
    protocol = "ssh-ng";
    maxJobs = 16;
    speedFactor = 1;
    supportedFeatures = [
      "benchmark"
      "big-parallel"
      "ca-derivations"
      "kvm"
      "nixos-test"
      "gccarch-x86-64-v2"
      "gccarch-x86-64-v3"
      "gccarch-znver2"
      "gccarch-znver3"
    ];
    mandatoryFeatures = [];
  };
in {
  programs.ssh.knownHosts.${hostName} = {
    hostNames = [hostName sshAlias];
    inherit publicKey;
  };

  environment.etc."ssh/ssh_config.d/100-${sshAlias}.conf".text = ''
    Host ${sshAlias}
      User ${sshUser}
      Hostname ${hostName}
      HostKeyAlias ${sshAlias}
      IdentityFile ${sshKey}
  '';

  nix.buildMachines = [
    (machine "x86_64-linux")
    (machine "i686-linux")
  ];
}
