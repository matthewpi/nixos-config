{pkgs, ...}: {
  imports = [
    ./firefox.nix
    ./gaming.nix
    # ./obs-studio.nix
    # ./signal.nix
    ./terminal.nix
    ./virt-manager.nix
    ./vscode.nix
    ./zen-browser.nix

    ../programs/zen-browser.nix
  ];

  home.packages = with pkgs; [
    amberol
    cider2
    libreoffice
    hoppscotch
    impression
    obsidian
    openlens
    protonmail-desktop
    qFlipper
    seabird
    slack
    switcheroo
    ungoogled-chromium
    vesktop
    video-trimmer
    wireshark
    zed-editor
  ];
}
