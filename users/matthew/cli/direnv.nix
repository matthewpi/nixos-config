{
  programs.direnv = {
    enable = true;
    enableBashIntegration = false;
    enableNushellIntegration = false;
    enableZshIntegration = true;

    nix-direnv = {
      enable = true;
    };
  };
}
