{
  isDesktop,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ./firefox.nix
      # ./obs-studio.nix
      # ./signal.nix
      ./terminal.nix
      ./vscode.nix
      # ./zen-browser.nix

      # ../programs/zen-browser.nix
    ]
    ++ lib.optionals isDesktop [
      ./gaming.nix
      ./virt-manager.nix
    ];

  home.packages = with pkgs; [
    amberol
    cider2
    libreoffice
    hoppscotch
    impression
    obsidian
    # lens
    protonmail-desktop
    qFlipper
    remmina
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
