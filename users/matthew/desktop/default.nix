{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./applications
    ./hyprland
    ./services

    ./gtk.nix
    ./streamdeck.nix
  ];

  home.packages = with pkgs; [
    # Install tcpdump
    tcpdump

    # Install nvtop
    nvtop-amd
  ];

  xdg.mimeApps = {
    enable = lib.mkDefault config.xdg.mime.enable;

    associations.added = {
      # While firefox's .desktop file sets these, Junction tries to explicitly set these associations.
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "application/xhtml+xml" = ["firefox.desktop"];
      "text/html" = ["firefox.desktop"];
      "text/xml" = ["firefox.desktop"];

      # GNOME Text Editor doesn't set any mime types.
      "application/xml" = ["org.gnome.TextEditor.desktop"];
      "application/x-x509-ca-cert" = ["org.gnome.TextEditor.desktop"];
      "audio/x-mod" = ["org.gnome.TextEditor.desktop"]; # go.mod
      "text/markdown" = ["org.gnome.TextEditor.desktop"];
      "text/plain" = ["org.gnome.TextEditor.desktop"];
      "text/vnd.trolltech.linguist" = ["org.gnome.TextEditor.desktop"]; # TypeScript
      "text/x-csrc" = ["org.gnome.TextEditor.desktop"]; # .cfg
    };

    defaultApplications = let
      defaultBrowser = "firefox.desktop";
      defaultImageViewer = "org.gnome.eog.desktop";
      defaultTextEditor = "org.gnome.TextEditor.desktop";
    in {
      # Web Browser
      "x-scheme-handler/http" = [defaultBrowser];
      "x-scheme-handler/https" = [defaultBrowser];
      "application/xhtml+xml" = [defaultBrowser];
      "text/html" = [defaultBrowser];
      "text/xml" = [defaultBrowser];

      # PDFs
      "application/pdf" = ["org.gnome.Evince.desktop"];

      # Image Viewer
      "image/jpeg" = [defaultImageViewer];
      "image/bmp" = [defaultImageViewer];
      "image/gif" = [defaultImageViewer];
      "image/jpg" = [defaultImageViewer];
      "image/pjpeg" = [defaultImageViewer];
      "image/png" = [defaultImageViewer];
      "image/tiff" = [defaultImageViewer];
      "image/webp" = [defaultImageViewer];
      "image/x-bmp" = [defaultImageViewer];
      "image/x-gray" = [defaultImageViewer];
      "image/x-icb" = [defaultImageViewer];
      "image/x-ico" = [defaultImageViewer];
      "image/x-png" = [defaultImageViewer];
      "image/x-portable-anymap" = [defaultImageViewer];
      "image/x-portable-bitmap" = [defaultImageViewer];
      "image/x-portable-graymap" = [defaultImageViewer];
      "image/x-portable-pixmap" = [defaultImageViewer];
      "image/x-xbitmap" = [defaultImageViewer];
      "image/x-xpixmap" = [defaultImageViewer];
      "image/x-pcx" = [defaultImageViewer];
      "image/svg+xml" = [defaultImageViewer];
      "image/svg+xml-compressed" = [defaultImageViewer];
      "image/vnd.wap.wbmp" = [defaultImageViewer];
      "image/x-icns" = [defaultImageViewer];

      # Text Editor
      "application/xml" = [defaultTextEditor];
      "application/x-x509-ca-cert" = [defaultTextEditor];
      "audio/x-mod" = [defaultTextEditor]; # go.mod
      "text/markdown" = [defaultTextEditor];
      "text/plain" = [defaultTextEditor];
      "text/vnd.trolltech.linguist" = [defaultTextEditor]; # TypeScript
      "text/x-csrc" = [defaultTextEditor]; # .cfg

      # Archives
      "application/zip" = ["org.gnome.FileRoller.desktop"];
    };
  };
}
