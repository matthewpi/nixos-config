let
  sshAlias = "builder-nxs";
  hostName = "nxs.blahaj.systems";

  sshUser = "builder";
  sshKey = "/etc/nix/builder_ed25519";

  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN6yPh8OeiYN5AZokTs8bZ1eiv2gSk803xnRTjQsIKZk";
  publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU42eVBoOE9laVlONUFab2tUczhiWjFlaXYyZ1NrODAzeG5SVGpRc0lLWmsK";

  machine = system: {
    hostName = sshAlias;
    inherit sshKey publicHostKey system;
    protocol = "ssh-ng";
    maxJobs = 32;
    speedFactor = 2;
    supportedFeatures = [
      "benchmark"
      "big-parallel"
      "ca-derivations"
      "kvm"
      "nixos-test"
      "gccarch-x86-64-v2"
      "gccarch-x86-64-v3"
      "gccarch-znver2"
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
