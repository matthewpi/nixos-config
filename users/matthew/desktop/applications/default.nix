{pkgs, ...}: {
  imports = [
    ./firefox.nix
    ./gaming.nix
    # ./obs-studio.nix
    # ./signal.nix
    ./terminal.nix
    ./virt-manager.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    amberol
    cider2
    libreoffice
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
