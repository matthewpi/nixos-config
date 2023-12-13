{
  imports = [
    ./libreoffice.nix
    ./obs-studio.nix
    # Disabled due to using an insecure electron version,
    # updating electron causes the app to break.
    #./obsidian.nix
  ];
}
