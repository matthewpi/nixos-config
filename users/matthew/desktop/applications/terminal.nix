{
  flavour,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [blackbox-terminal termius];

  programs.alacritty = {
    enable = true;

    settings = {
      import = ["${pkgs.catppuccin}/alacritty/Catppuccin-${flavour}.toml"];

      env = {
        TERM_PROGRAM = "alacritty";
        TERM = "xterm-256color";
      };

      window.decorations = "Full";

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

  dconf.settings = {
    "com/raggesilver/BlackBox" = {
      #
      # General
      #

      # Show Borders
      window-show-borders = false;

      # Theme Integration
      pretty = false;

      #
      # Terminal
      #

      font = "MonaspiceNe Nerd Font 10";

      easy-copy-paste = true;

      opacity = lib.hm.gvariant.mkUint32 100;

      notify-process-completion = false;

      theme-dark = "Catppuccin-${flavour}";
      theme-light = "Catppuccin-latte";
    };
  };

  xdg.dataFile = {
    "blackbox/schemes/Catppuccin-frappe.json".source = "${pkgs.catppuccin}/blackbox/Catppuccin-frappe.json";
    "blackbox/schemes/Catppuccin-latte.json".source = "${pkgs.catppuccin}/blackbox/Catppuccin-latte.json";
    "blackbox/schemes/Catppuccin-macchiato.json".source = "${pkgs.catppuccin}/blackbox/Catppuccin-macchiato.json";
    "blackbox/schemes/Catppuccin-mocha.json".source = "${pkgs.catppuccin}/blackbox/Catppuccin-mocha.json";
  };
}
