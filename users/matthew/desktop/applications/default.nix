{pkgs, ...}: {
  imports = [
    ./firefox
    ./gaming
    ./discord.nix
    ./freelens.nix
    ./tailscale.nix
    ./terminal.nix
    # ./vscode.nix
    ./zed-editor.nix
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
