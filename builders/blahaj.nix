let
  sshAlias = "builder-blahaj";
  hostName = "blahaj.blahaj.systems";
in {
  programs.ssh.extraConfig = ''
    Host ${sshAlias}
      User builder
      HostName ${hostName}
      IdentitiesOnly yes
      IdentityFile /root/.ssh/id_ed25519
  '';

  programs.ssh.knownHosts = {
    ${hostName} = {
      hostNames = [hostName];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2GQbheOCOd7QjlTCFLC2ZJzImc0I14l8cj5fAsS+aK";
    };
  };

  nix.buildMachines = [
    {
      hostName = sshAlias;
      system = "x86_64-linux";
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
        "gccarch-znver3"
      ];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUoyR1FiaGVPQ09kN1FqbFRDRkxDMlpKekltYzBJMTRsOGNqNWZBc1MrYUsgcm9vdEBibGFoYWoK";
    }
    {
      hostName = sshAlias;
      system = "i686-linux";
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
        "gccarch-znver3"
      ];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUoyR1FiaGVPQ09kN1FqbFRDRkxDMlpKekltYzBJMTRsOGNqNWZBc1MrYUsgcm9vdEBibGFoYWoK";
    }
  ];

  nix.settings = {
    trusted-substituters = ["https://cache.blahaj.systems"];
    trusted-public-keys = ["cache.blahaj.systems:NV3iFToViaqHGNorfWVMXgkwGq/YWTdzopehQlyEmU8="];
  };
}
