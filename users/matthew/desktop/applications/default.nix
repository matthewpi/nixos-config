{
  isDesktop,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ./firefox.nix
      ./gauntlet.nix
      # ./obs-studio.nix
      # ./signal.nix
      ./terminal.nix
      ./vscode.nix
      ./zed-editor.nix
    ]
    ++ lib.optionals isDesktop [
      ./gaming.nix
      ./virt-manager.nix
    ];

  home.packages = with pkgs; [
    amberol
    cider2
    libreoffice
    hoppscotch-desktop
    impression
    obsidian
    ledger-live-desktop
    # lens
    protonmail-desktop
    qFlipper
    remmina
    resources
    seabird
    slack
    switcheroo
    ungoogled-chromium
    vesktop
    video-trimmer
    wireshark
  ];
}
