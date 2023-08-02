{
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = false;
    };
    extensions = [];
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
