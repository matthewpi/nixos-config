{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Include the 1Password bookmarks config, this also helps ensure we only
    # use the proper SSH key for the host.
    includes = ["~/.ssh/1Password/config"];

    settings = {
      "Host *" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        # Change the known_hosts location to outside `~/.ssh` as `~/.ssh` is not
        # persisted by impermanence.
        UserKnownHostsFile = "~/.cache/ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
}
