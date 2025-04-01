{
  isDesktop,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ./firefox
      ./tailscale.nix
      ./terminal.nix
      ./vesktop.nix
      ./vscode.nix
      ./zed-editor.nix
    ]
    ++ lib.optionals isDesktop [
      ./gaming
      # ./virt-manager.nix
    ];

  home.packages = with pkgs; [
    amberol
    cider2
    kooha
    # TODO: re-enable once fixed
    # hoppscotch-desktop
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
