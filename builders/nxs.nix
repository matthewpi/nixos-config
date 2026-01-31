let
  sshAlias = "builder-nxs";
  hostName = "nxs.blahaj.systems";
in {
  nix.settings = {
    trusted-substituters = ["https://nxs.blahaj.systems"];
    trusted-public-keys = ["nxs.blahaj.systems:81cbdJwZju4jW0Drx5yJZV0FhPWYSgLLpV6PEeCb8YM="];
  };

  programs.ssh.extraConfig = ''
    Host ${sshAlias}
      User builder
      HostName ${hostName}
      IdentitiesOnly yes
      IdentityFile /root/.ssh/id_ed25519
  '';

  programs.ssh.knownHosts.${hostName} = {
    hostNames = [hostName];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN6yPh8OeiYN5AZokTs8bZ1eiv2gSk803xnRTjQsIKZk";
  };

  nix.buildMachines = [
    {
      hostName = sshAlias;
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 32;
      speedFactor = 2;
      supportedFeatures = [
        "kernel-module-keys"
        "secureboot"
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
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU42eVBoOE9laVlONUFab2tUczhiWjFlaXYyZ1NrODAzeG5SVGpRc0lLWmsK";
    }
    {
      hostName = sshAlias;
      system = "i686-linux";
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
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU42eVBoOE9laVlONUFab2tUczhiWjFlaXYyZ1NrODAzeG5SVGpRc0lLWmsK";
    }
  ];
}
