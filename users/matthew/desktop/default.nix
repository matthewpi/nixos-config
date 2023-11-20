{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./applications
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
