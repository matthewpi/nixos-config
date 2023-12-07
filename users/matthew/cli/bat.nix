{
  flavour,
  pkgs,
  ...
}: {
  programs.bat = {
    enable = true;

    config = {
      theme = "Catppuccin-${flavour}";
    };

    themes = {
      Catppuccin-frappe = {
        src = pkgs.catppuccin;
        file = "bat/Catppuccin-frappe.tmTheme";
      };
      Catppuccin-latte = {
        src = pkgs.catppuccin;
        file = "bat/Catppuccin-latte.tmTheme";
      };
      Catppuccin-macchiato = {
        src = pkgs.catppuccin;
        file = "bat/Catppuccin-macchiato.tmTheme";
      };
      Catppuccin-mocha = {
        src = pkgs.catppuccin;
        file = "bat/Catppuccin-mocha.tmTheme";
      };
    };
  };
}
