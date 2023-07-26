{
  programs.atuin = {
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableNushellIntegration = false;
    enableZshIntegration = true;

    settings = {
      auto_sync = false;
      update_check = false;
      search_mode = "prefix";
      filter_mode = "host";
    };
  };
}
