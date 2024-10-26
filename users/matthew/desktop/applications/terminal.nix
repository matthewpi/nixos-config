{
  programs.alacritty = {
    enable = true;

    settings = {
      env = {
        TERM_PROGRAM = "alacritty";
        TERM = "xterm-256color";
      };

      window = {
        decorations = "None";
        opacity = 0.75;
        blur = true;
      };

      font = {
        size = 10.0;
        normal.family = "MonaspiceNe Nerd Font";
      };

      cursor.style.shape = "Beam";

      ipc_socket = false;

      keyboard.bindings = [
        {
          mods = "Control";
          key = "V";
          action = "Paste";
        }
      ];
    };
  };
}
