{
  flavour,
  lib,
  pkgs,
  ...
}: {
  programs.bat = {
    enable = true;

    config = {
      theme = "Catppuccin ${lib.strings.toUpper (builtins.substring 0 1 flavour)}${builtins.substring 1 (-1) flavour}";
    };

    themes = {
      "Catppuccin Frappe" = {
        src = pkgs.catppuccin;
        file = "bat/Catppuccin Frappe.tmTheme";
      };
      "Catppuccin Latte" = {
        src = pkgs.catppuccin;
        file = "bat/Catppuccin Latte.tmTheme";
      };
      "Catppuccin Macchiato" = {
        src = pkgs.catppuccin;
        file = "bat/Catppuccin Macchiato.tmTheme";
      };
      "Catppuccin Mocha" = {
        src = pkgs.catppuccin;
        file = "bat/Catppuccin Mocha.tmTheme";
      };
    };
  };
}
