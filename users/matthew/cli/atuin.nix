{
  programs.atuin = {
    enable = true;

    # daemon.enable = true;

    settings = {
      update_check = false;
      search_mode = "prefix";
      filter_mode = "host";

      auto_sync = true;
      sync_address = "https://atuin.blahaj.systems";
      sync_frequency = "15m";

      inline_height = 0;
    };
  };
}
