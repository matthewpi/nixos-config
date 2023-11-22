{
  flavour,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [blackbox-terminal termius];

  dconf.settings = let
    _flavour = lib.strings.concatStrings [
      (lib.strings.toUpper (builtins.substring 0 1 flavour))
      (builtins.substring 1 (builtins.stringLength flavour) flavour)
    ];
  in {
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

      font = "Hack Nerd Font Mono 10";

      opacity = lib.hm.gvariant.mkUint32 75;

      notify-process-completion = false;

      theme-dark = "Catppuccin-${_flavour}";
      theme-light = "Catppuccin-Latte";
    };
  };

  xdg.dataFile = let
    catppuccin = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "blackbox";
      rev = "ba04186c5b722926b538a71b2186be5bf32894d1";
      hash = "sha256-JkbJbdCP0ple0t7k/DlXtVKwluATCnf2kbRcryGlViM=";
    };
  in {
    "blackbox/schemes/Catppuccin-Frappe.json".text = builtins.readFile (catppuccin + /src/Catppuccin-Frappe.json);
    "blackbox/schemes/Catppuccin-Latte.json".text = builtins.readFile (catppuccin + /src/Catppuccin-Latte.json);
    "blackbox/schemes/Catppuccin-Macchiato.json".text = builtins.readFile (catppuccin + /src/Catppuccin-Macchiato.json);
    "blackbox/schemes/Catppuccin-Mocha.json".text = builtins.readFile (catppuccin + /src/Catppuccin-Mocha.json);

    "blackbox/user-keymap.json".source = (pkgs.formats.json {}).generate "user-keymap.json" {
      keymap = {
        "win.new_tab" = ["<Shift><Control>t"];
        "win.zoom-in" = ["<Shift><Control>plus"];
        "win.zoom-out" = ["<Control>minus"];
        "win.switch-tab-1" = ["<Alt>1"];
        "win.edit_preferences" = ["<Control>comma"];
        "win.switch-tab-2" = ["<Alt>2"];
        "win.search" = ["<Shift><Control>f"];
        "win.switch-tab-3" = ["<Alt>3"];
        "app.new-window" = ["<Shift><Control>n"];
        "win.fullscreen" = ["F11"];
        "win.switch-tab-4" = ["<Alt>4"];
        "app.focus-previous-tab" = ["<Shift><Control>Tab"];
        "win.switch-tab-5" = ["<Alt>5"];
        "win.switch-tab-6" = ["<Alt>6"];
        "win.zoom-default" = ["<Shift><Control>parenright"];
        "win.switch-tab-7" = ["<Alt>7"];
        "win.paste" = ["<Control>v"];
        "win.show-help-overlay" = ["<Shift><Control>question"];
        "win.switch-tab-8" = ["<Alt>8"];
        "win.switch-tab-9" = ["<Alt>9"];
        "win.switch-tab-last" = ["<Alt>0"];
        "app.focus-next-tab" = ["<Control>Tab"];
        "win.switch-headerbar-mode" = ["<Shift><Control>h"];
        "win.copy" = ["<Shift><Control>c"];
        "win.close-tab" = ["<Shift><Control>w"];
      };
    };
  };
}
