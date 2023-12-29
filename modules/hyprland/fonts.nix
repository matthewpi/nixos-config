{
  lib,
  pkgs,
  ...
}: {
  # Configure fonts
  fonts = {
    fontconfig = {
      defaultFonts = {
        serif = lib.mkDefault ["Inter"];
        sansSerif = lib.mkDefault ["Inter"];
        monospace = lib.mkDefault ["Monaspace Neon"];
        emoji = lib.mkDefault ["Noto Color Emoji"];
      };
    };

    fontDir.enable = true;

    packages = with pkgs; [
      inter
      hack-font
      monaspace
      (nerdfonts.override {
        fonts = ["Hack" "Monaspace"];
      })
    ];
  };
}
