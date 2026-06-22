let
  sshAlias = "builder-desktop";
  hostName = "matthew-desktop.moose-nase.ts.net";

  sshUser = "builder";
  sshKey = "/etc/nix/builder_ed25519";

  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxm6O+htsvd/wVMxC2VSE4R2zlvXA8Eo3HeZusbogZg";
  publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUp4bTZPK2h0c3ZkL3dWTXhDMlZTRTRSMnpsdlhBOEVvM0hlWnVzYm9nWmc=";

  machine = system: {
    hostName = sshAlias;
    inherit sshKey publicHostKey system;
    protocol = "ssh-ng";
    maxJobs = 16;
    speedFactor = 3;
    supportedFeatures = [
      "benchmark"
      "big-parallel"
      "ca-derivations"
      "kvm"
      "nixos-test"
      "gccarch-x86-64-v2"
      "gccarch-x86-64-v3"
      "gccarch-x86-64-v4"
      "gccarch-znver2"
      "gccarch-znver3"
      "gccarch-znver4"
      "gccarch-znver5"

      "kernel-module-keys"
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
