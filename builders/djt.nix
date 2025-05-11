{
  programs.ssh.extraConfig = ''
    Host builder-djt
      User builder
      HostName djt.nxpkgs.dev
      IdentitiesOnly yes
      IdentityFile %d/.ssh/id_ed25519
      ControlMaster auto
      ControlPath %d/.cache/ssh/control/%r@%h:%p
      ControlPersist 120
  '';

  programs.ssh.knownHosts = {
    "djt.nxpkgs.dev".hostNames = ["djt.nxpkgs.dev"];
    "djt.nxpkgs.dev".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqPIM0LeXZLzSRSkCi71AyrNc054cOqMv8CTszQSyEb";
  };

  # nix.buildMachines = [
  #   {
  #     hostName = "builder-djt";
  #     system = "x86_64-linux";
  #     protocol = "ssh-ng";
  #     maxJobs = 16;
  #     speedFactor = 1;
  #     supportedFeatures = [
  #       "benchmark"
  #       "big-parallel"
  #       "ca-derivations"
  #       "kvm"
  #       "nixos-test"
  #       "gccarch-x86-64-v2"
  #       "gccarch-x86-64-v3"
  #       "gccarch-znver3"
  #     ];
  #     mandatoryFeatures = [];
  #     publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUdxUElNMExlWFpMelNSU2tDaTcxQXlyTmMwNTRjT3FNdjhDVHN6UVN5RWI=";
  #   }
  # ];

  nix.settings = {
    trusted-substituters = ["https://djt.moose-nase.ts.net"];
    trusted-public-keys = ["djt.nxpkgs.dev-1:IPbZL4PYlQ99i9GKE+ZN6IhK/NlLZJw0wBVVweipaOI="];
  };
}
