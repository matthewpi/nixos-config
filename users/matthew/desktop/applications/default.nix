{
  isDesktop,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ./firefox.nix
      ./tailscale.nix
      ./terminal.nix
      ./vesktop.nix
      ./vscode.nix
      ./zed-editor.nix
    ]
    ++ lib.optionals isDesktop [
      ./gaming.nix
      # ./virt-manager.nix
    ];

  home.packages = with pkgs; [
    amberol
    cider2
    kooha
    hoppscotch-desktop
    impression
    libreoffice
    ledger-live-desktop
    obsidian
    overskride
    qFlipper
    resources
    seabird
    slack
    switcheroo
    ungoogled-chromium
    video-trimmer
    wireshark
  ];
}
