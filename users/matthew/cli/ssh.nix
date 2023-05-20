{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "*" = {
        extraOptions = {
          # Configure the 1Password SSH agent
          IdentityAgent = "~/.1password/agent.sock";
          # Change the known_hosts location to outside .ssh as that directory is read-only when
          # impermanence is enabled
          UserKnownHostsFile = "~/.cache/ssh/known_hosts";
        };
      };
    };
  };
}
