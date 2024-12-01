{
  lib,
  pkgs,
  ...
}: {
  # Configure fonts
  fonts = {
    enableDefaultPackages = true;

    fontconfig = {
      defaultFonts = {
        serif = lib.mkDefault ["Inter"];
        sansSerif = lib.mkDefault ["Inter"];
        monospace = lib.mkDefault ["MonaspiceNe Nerd Font Mono"];
        emoji = lib.mkDefault ["Noto Color Emoji"];
      };
    };

    fontDir.enable = true;

    packages = with pkgs; [
      inter
      hack-font
      monaspace
      nerd-fonts.hack
      nerd-fonts.monaspace
    ];
  };
}
