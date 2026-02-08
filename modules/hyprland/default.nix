{
  flake.nixosModules.hyprland = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      ./greetd
      ./gsettings.nix

      inputs.catppuccin.nixosModules.catppuccin
    ];

    # Enable Catppuccin colors on the TTY.
    catppuccin.tty.enable = true;

    # Disable XWayland since we don't need it for any applications.
    programs.xwayland.enable = lib.mkDefault false;

    # Configure Hyprland and it's package.
    programs.hyprland = {
      # NOTE: this is intentional, if we enable this a bunch of settings get
      # configured at the NixOS level, some of which we don't want (XDG portals).
      #
      # Most of our configuration is done at the home-manager level, so we only
      # want the basic essentials in the NixOS config.
      enable = false;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      xwayland.enable = config.programs.xwayland.enable;
    };

    # Configure a display manager session for Hyprland using the absolute path
    # to `start-hyprland`.
    services.displayManager.sessionPackages = [
      (pkgs.writeTextFile {
        name = "hyprland";
        text = ''
          [Desktop Entry]
          Name=Hyprland
          Comment=An intelligent dynamic tiling Wayland compositor
          Exec=${lib.getExe' config.programs.hyprland.package "start-hyprland"}
          Type=Application
          DesktopNames=Hyprland
          Keywords=tiling;wayland;compositor;
        '';
        destination = "/share/wayland-sessions/hyprland.desktop";
        derivationArgs.passthru.providedSessions = ["hyprland"];
      })
    ];

    # Add required packages to path.
    environment.systemPackages = [
      config.programs.hyprland.package
      pkgs.nixos-icons
      pkgs.pciutils
      pkgs.xdg-utils
    ];

    # Configure hyprlock PAM.
    security.pam.services.hyprlock = {
      # Enable gnome-keyring integration only if gnome-keyring is enabled.
      enableGnomeKeyring = lib.mkDefault config.services.gnome.gnome-keyring.enable;

      # Disable fprint auth since hyprlock supports accessing fprintd using DBUS.
      fprintAuth = false;
    };

    # Ensure fprintAuth for login is disabled, otherwise the keyring will never
    # be unlocked since it requires a password at least once per-boot.
    security.pam.services.login.fprintAuth = false;

    # Enable GNOME keyring.
    #
    # This configures system components, but not a service for GNOME keyring,
    # the GNOME keyring service is configured under home-manager.
    services.gnome.gnome-keyring.enable = lib.mkDefault true;
    services.gnome.gcr-ssh-agent.enable = lib.mkDefault false;

    # Enable upower for power management.
    services.upower = {
      enable = lib.mkDefault true;
      criticalPowerAction = lib.mkDefault "PowerOff";
    };

    # Enable gvfs.
    services.gvfs = {
      enable = lib.mkDefault true;
      package = pkgs.gvfs.override {
        avahi = null;
        samba = null;
      };
    };

    # Enable glib-networking.
    services.gnome.glib-networking.enable = lib.mkDefault true;

    # Enable services required for GNOME Calendar.
    services.gnome.gnome-online-accounts.enable = lib.mkDefault true;
    services.gnome.evolution-data-server.enable = lib.mkDefault true;

    # Fixes issues with XDG portal definitions not being detected.
    # ref; https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
    # environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];

    services.graphical-desktop.enable = lib.mkDefault false;
    hardware.graphics.enable = lib.mkDefault true;
    services.speechd.enable = lib.mkDefault false;

    environment.etc."X11/xorg.conf.d/00-keyboard.conf".text = ''
      Section "InputClass"
        Identifier "Keyboard catchall"
        MatchIsKeyboard "on"
        Option "XkbModel" "${config.services.xserver.xkb.model}"
        Option "XkbLayout" "${config.services.xserver.xkb.layout}"
        Option "XkbOptions" "${config.services.xserver.xkb.options}"
        Option "XkbVariant" "${config.services.xserver.xkb.variant}"
      EndSection
    '';

    # Disable linking of xdg-autostart files for globally installed packages.
    xdg.autostart.enable = lib.mkDefault false;

    # TODO: remove `"/etc/xdg"` from `<nixpkgs>/nixos/modules/config/system-path.nix`.
    environment.pathsToLink = lib.mkForce [
      "/share/gsettings-schemas/glib-2.0"
      "/share/applications"
      "/share/xdg-desktop-portal"
      "/etc/profile.d"
      "/etc/dbus-1"
      "/share/dbus-1"
      "/share/polkit-1"
      "/share/zsh"
      "/share/X11"
      "/share/nix-ld"
      "/share/nano"
      "/lib/gtk-2.0"
      "/lib/gtk-3.0"
      "/lib/gtk-4.0"
      "/etc/bash_completion.d"
      "/share/bash-completion"
      "/share/man"
      "/share/info"
      "/share/doc"
      "/share/gtk-doc"
      "/share/devhelp"
      "/share/sounds"
      "/share/mime"
      "/share/applications"
      "/share/desktop-directories"
      "/etc/xdg/menus"
      "/etc/xdg/menus/applications-merged"
      "/share/icons"
      "/share/pixmaps"
      "/share/terminfo"
      "/bin"
      # "/etc/xdg"
      "/etc/gtk-2.0"
      "/etc/gtk-3.0"
      "/lib"
      "/sbin"
      "/share/emacs"
      "/share/hunspell"
      "/share/org"
      "/share/themes"
      "/share/vulkan"
      "/share/kservices5"
      "/share/kservicetypes5"
      "/share/kxmlgui5"
      "/share/systemd"
      "/share/thumbnailers"
      "/share/X11/fonts"
      "/share/metainfo"
      "/share/appdata"
    ];
  };
}
