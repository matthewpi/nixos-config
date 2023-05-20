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
      Catppuccin-frappe = builtins.readFile (catppuccin + /Catppuccin-frappe.tmTheme);
      Catppuccin-latte = builtins.readFile (catppuccin + /Catppuccin-latte.tmTheme);
      Catppuccin-macchiato = builtins.readFile (catppuccin + /Catppuccin-macchiato.tmTheme);
      Catppuccin-mocha = builtins.readFile (catppuccin + /Catppuccin-mocha.tmTheme);
    };
  };

  # TODO: automatically generate this directory using `bat cache --build`, otherwise
  # the themes will not be available.
}
