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

    themes = let
      catppuccin = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
        hash = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
      };
    in {
      Catppuccin-frappe = {
        src = catppuccin;
        file = "Catppuccin-frappe.tmTheme";
      };
      Catppuccin-latte = {
        src = catppuccin;
        file = "Catppuccin-latte.tmTheme";
      };
      Catppuccin-macchiato = {
        src = catppuccin;
        file = "Catppuccin-macchiato.tmTheme";
      };
      Catppuccin-mocah = {
        src = catppuccin;
        file = "Catppuccin-mocha.tmTheme";
      };
    };
  };
}
