let
  # Hosts
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxm6O+htsvd/wVMxC2VSE4R2zlvXA8Eo3HeZusbogZg";
  hosts = [desktop];

  # Users
  matthew = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ30VI7vAdrs2MDgkNHSQMJt2xBtBLrirVhinSyteeU";
  users = [matthew];
in {
  "passwordfile-matthew.age".publicKeys = users ++ hosts;
}
