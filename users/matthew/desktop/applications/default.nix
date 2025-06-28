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
    hoppscotch-desktop
    impression
    ladybird
    libreoffice
    ledger-live-desktop
    obsidian
    overskride
    qFlipper
    resources
    seabird
    signal-desktop
    slack
    switcheroo
    ungoogled-chromium
    video-trimmer
    wireshark
  ];
}
