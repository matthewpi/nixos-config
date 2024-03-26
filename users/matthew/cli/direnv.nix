{
  programs.direnv = {
    enable = true;
    enableBashIntegration = false;
    enableNushellIntegration = false;
    enableZshIntegration = true;

    config = {
      hide_env_diff = true;
    };

    nix-direnv = {
      enable = true;
    };
  };
}
