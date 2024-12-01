{pkgs, ...}: {
  # Ensure the proper gsettings-schemas are installed and properly accessible.
  environment.pathsToLink = ["/share/gsettings-schemas/glib-2.0"];
  environment.systemPackages = [
    (pkgs.runCommand "gsettings-schemas" {
        nativeBuildInputs = with pkgs; [glib];

        # TODO: see if there is a better way to do this without needing to manually specify packages
        # that have gsettings-schemas.
        paths = with pkgs; [
          gsettings-desktop-schemas
          gtk3
          gtk4

          amberol
          impression
          switcheroo
          video-trimmer

          epiphany
          evince
          dconf-editor
          eog
          file-roller
          geary
          gnome-calculator
          gnome-calendar
          gnome-characters
          gnome-clocks
          gnome-contacts
          gnome-disk-utility
          gnome-font-viewer
          gnome-logs
          gnome-maps
          gnome-text-editor
          gnome-weather
          nautilus
          seahorse
          sushi
          totem
          wordbook
        ];
      } ''
        mkdir schemas
        # Get the gsettings-schemas for all paths
        for path in $paths; do
          cp $path/share/gsettings-schemas/*/glib-2.0/schemas/*.xml ./schemas || :
          cp $path/share/gsettings-schemas/*/glib-2.0/schemas/*.override ./schemas || :
        done

        # Compile all the schemas
        glib-compile-schemas ./schemas

        mkdir -p "$out/share/gsettings-schemas/glib-2.0"
        cp -r schemas "$out/share/gsettings-schemas/glib-2.0/"
      '')
  ];

  environment.sessionVariables = {
    XDG_DATA_DIRS = ["/run/current-system/sw/share/gsettings-schemas"];
    GSETTINGS_SCHEMAS_PATH = "/run/current-system/sw/share/gsettings-schemas";
  };
}
