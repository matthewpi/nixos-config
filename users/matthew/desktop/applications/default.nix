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
