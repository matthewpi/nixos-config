{
  lib,
  pkgs,
  ...
}: {
  # Configure fonts
  fonts = {
    enableDefaultPackages = true;

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = lib.mkDefault ["Inter"];
        sansSerif = lib.mkDefault ["Inter"];
        monospace = lib.mkDefault ["Monaspace Neon NF"];
        emoji = lib.mkDefault ["Noto Color Emoji"];
      };
    };

    fontDir.enable = true;

    packages = with pkgs; [
      inter
      monaspace.otf
      monaspace.nerdfonts
    ];
  };
}
