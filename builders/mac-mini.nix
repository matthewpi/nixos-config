let
  sshAlias = "builder-mac-mini";
  hostName = "matthews-mac-mini.moose-nase.ts.net";
in {
  programs.ssh.extraConfig = ''
    Host ${sshAlias}
      User _builder
      HostName ${hostName}
      IdentitiesOnly yes
      IdentityFile /root/.ssh/id_ed25519
  '';

  programs.ssh.knownHosts.${hostName} = {
    hostNames = [hostName];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqa8qpnd0xcqJ2CP/jtXEc9YolbYU8IIZLgA5jI6ZcQ";
  };

  nix.buildMachines = [
    {
      hostName = sshAlias;
      system = "aarch64-darwin";
      protocol = "ssh-ng";
      maxJobs = 8;
      speedFactor = 1;
      supportedFeatures = ["big-parallel" "ca-derivations"];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1xYThxcG5kMHhjcUoyQ1AvanRYRWM5WW9sYllVOElJWkxnQTVqSTZaY1Eg";
    }
    {
      hostName = sshAlias;
      system = "aarch64-linux";
      protocol = "ssh-ng";
      maxJobs = 8;
      speedFactor = 1;
      supportedFeatures = ["big-parallel" "ca-derivations"];
      mandatoryFeatures = [];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1xYThxcG5kMHhjcUoyQ1AvanRYRWM5WW9sYllVOElJWkxnQTVqSTZaY1Eg";
    }
  ];
}
