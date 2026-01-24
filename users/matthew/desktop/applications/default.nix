{
  isDesktop,
  pkgs,
  ...
}: {
  imports = [
    ./firefox
    ./gaming
    ./discord.nix
    ./flatpak.nix
    ./freelens.nix
    ./supersonic.nix
    ./tailscale.nix
    ./terminal.nix
    ./virt-manager.nix
    ./zed-editor.nix
  ];

  home.packages = with pkgs;
    [
      amberol
      cartero
      gnome-online-accounts-gtk
      kooha
      impression
      # ladybird
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

      libreoffice
      hunspell
      hunspellDicts.en_CA
      hunspellDicts.en_US

      jetbrains.idea-oss
    ]
    ++ lib.optional isDesktop polychromatic;
}
