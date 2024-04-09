let
  # Hosts
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxm6O+htsvd/wVMxC2VSE4R2zlvXA8Eo3HeZusbogZg";
  hosts = [desktop];

  # Users
  matthew = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ30VI7vAdrs2MDgkNHSQMJt2xBtBLrirVhinSyteeU";
  users = [matthew];
in {
  "passwordfile-matthew.age".publicKeys = hosts ++ users;

  "restic-matthew-code.age".publicKeys = hosts ++ users;
  "restic-matthew-code-repository.age".publicKeys = hosts ++ users;
  "restic-matthew-code-password.age".publicKeys = hosts ++ users;

  "desktop-resolved.age".publicKeys = hosts ++ users;
}
