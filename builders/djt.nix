{
  programs.ssh.extraConfig = ''
    Host builder-djt
      User builder
      HostName djt.nxpkgs.dev
      IdentitiesOnly yes
      IdentityFile /root/.ssh/id_ed25519
  '';

  programs.ssh.knownHosts = {
    "djt.nxpkgs.dev".hostNames = ["djt.nxpkgs.dev"];
    "djt.nxpkgs.dev".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEpm9X2rHNLnYm848JQH9FXoZfoA490A7zJFYocEHON";
  };

  nix.buildMachines = [
    {
      hostName = "builder-djt";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 16;
      speedFactor = 2;
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
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBFcG05WDJySE5MblltODQ4SlFIOUZYb1pmb0E0OTBBN3pKRllvY0VIT04gCg==";
    }
  ];

  nix.settings.trusted-substituters = ["ssh-ng://builder-djt"];
}
