{
  programs.gh = {
    enable = true;
    enableGitCredentialHelper = false;
    extensions = [];
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
