let
  sshAlias = "builder-nxs";
  hostName = "nxs.blahaj.systems";
in {
  programs.ssh.extraConfig = ''
    Host ${sshAlias}
      User builder
      HostName ${hostName}
      IdentitiesOnly yes
      IdentityFile %d/.ssh/id_ed25519
      ControlMaster auto
      ControlPath %d/.cache/ssh/control/%r@%h:%p
      ControlPersist 120
  '';

  programs.ssh.knownHosts = {
    ${hostName} = {
      hostNames = [hostName];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN6yPh8OeiYN5AZokTs8bZ1eiv2gSk803xnRTjQsIKZk";
    };
  };

  nix.buildMachines = [
    {
      hostName = sshAlias;
      system = "x86_64-linux";
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
