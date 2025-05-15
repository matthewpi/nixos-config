{
  programs.ssh = {
    enable = true;

    # Include the 1Password bookmarks config, this also helps ensure we only
    # use the proper SSH key for the host.
    includes = ["~/.ssh/1Password/config"];

    matchBlocks."*".extraOptions = {
      # Change the known_hosts location to outside `~/.ssh` as `~/.ssh` is not
      # persisted by impermanence.
      UserKnownHostsFile = "~/.cache/ssh/known_hosts";
    };
  };
}
