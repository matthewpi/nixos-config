{
  programs.atuin = {
    enable = true;

    # daemon.enable = true;

    settings = {
      auto_sync = false;
      update_check = false;
      search_mode = "prefix";
      filter_mode = "host";

      inline_height = 0;
    };
  };
}
