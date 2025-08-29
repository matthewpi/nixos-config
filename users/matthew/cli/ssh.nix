{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Include the 1Password bookmarks config, this also helps ensure we only
    # use the proper SSH key for the host.
    includes = ["~/.ssh/1Password/config"];

    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      # Change the known_hosts location to outside `~/.ssh` as `~/.ssh` is not
      # persisted by impermanence.
      userKnownHostsFile = "~/.cache/ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
  };
}
