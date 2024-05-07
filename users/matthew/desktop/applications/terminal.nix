{
  flavour,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [termius];

  programs.alacritty = {
    enable = true;

    settings = {
      import = ["${pkgs.catppuccin}/alacritty/Catppuccin-${flavour}.toml"];

      env = {
        TERM_PROGRAM = "alacritty";
        TERM = "xterm-256color";
      };

      window = {
        decorations = "None";
        opacity = 0.8;
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
