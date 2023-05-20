{
  programs.ssh = {
    enable = true;

    # TODO: find out why this creates two host blocks, maybe find a way to disable the defaults and manually specify them here?
    matchBlocks = {
      "*" = {
        extraOptions = {
          IdentityAgent = "~/.1password/agent.sock";
          UserKnownHostsFile = "~/.cache/ssh/known_hosts";
        };
      };
    };
  };
}
