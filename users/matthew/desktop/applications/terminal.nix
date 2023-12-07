{
  flavour,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [blackbox-terminal termius];

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

      opacity = lib.hm.gvariant.mkUint32 75;

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

    # "blackbox/user-keymap.json".source = (pkgs.formats.json {}).generate "user-keymap.json" {
    #   keymap = {
    #     "win.new_tab" = ["<Shift><Control>t"];
    #     "win.zoom-in" = ["<Shift><Control>plus"];
    #     "win.zoom-out" = ["<Control>minus"];
    #     "win.switch-tab-1" = ["<Alt>1"];
    #     "win.edit_preferences" = ["<Control>comma"];
    #     "win.switch-tab-2" = ["<Alt>2"];
    #     "win.search" = ["<Shift><Control>f"];
    #     "win.switch-tab-3" = ["<Alt>3"];
    #     "app.new-window" = ["<Shift><Control>n"];
    #     "win.fullscreen" = ["F11"];
    #     "win.switch-tab-4" = ["<Alt>4"];
    #     "app.focus-previous-tab" = ["<Shift><Control>Tab"];
    #     "win.switch-tab-5" = ["<Alt>5"];
    #     "win.switch-tab-6" = ["<Alt>6"];
    #     "win.zoom-default" = ["<Shift><Control>parenright"];
    #     "win.switch-tab-7" = ["<Alt>7"];
    #     "win.paste" = ["<Control>v"];
    #     "win.show-help-overlay" = ["<Shift><Control>question"];
    #     "win.switch-tab-8" = ["<Alt>8"];
    #     "win.switch-tab-9" = ["<Alt>9"];
    #     "win.switch-tab-last" = ["<Alt>0"];
    #     "app.focus-next-tab" = ["<Control>Tab"];
    #     "win.switch-headerbar-mode" = ["<Shift><Control>h"];
    #     "win.copy" = ["<Shift><Control>c"];
    #     "win.close-tab" = ["<Shift><Control>w"];
    #   };
    # };
  };
}
