{
  config,
  lib,
  nixosConfig,
  ...
}: let
  defaultBrowser = "firefox.desktop";
  defaultImageViewer = "org.gnome.Loupe.desktop";
  defaultTextEditor = "org.gnome.TextEditor.desktop";
  defaultFileBrowser = "org.gnome.Nautilus.desktop";
in {
  xdg.mimeApps = {
    enable = lib.mkDefault config.xdg.mime.enable;

    associations.added =
      {
        # Directory Browser
        "inode/directory" = [defaultFileBrowser];

        # While firefox's .desktop file sets these, Junction tries to explicitly set these associations.
        "x-scheme-handler/http" = [defaultImageViewer];
        "x-scheme-handler/https" = [defaultImageViewer];
        "application/xhtml+xml" = [defaultImageViewer];
        "text/html" = [defaultImageViewer];
        "text/xml" = [defaultImageViewer];

        # GNOME Text Editor doesn't set any mime types.
        "application/xml" = [defaultTextEditor];
        "application/x-x509-ca-cert" = [defaultTextEditor];
        "audio/x-mod" = [defaultTextEditor]; # go.mod
        "text/markdown" = [defaultTextEditor];
        "text/plain" = [defaultTextEditor];
        "text/vnd.trolltech.linguist" = [defaultTextEditor]; # TypeScript
        "text/x-csrc" = [defaultTextEditor]; # .cfg
      }
      // lib.optionalAttrs nixosConfig.programs._1password-gui.enable {
        "x-scheme-handler/onepassword" = ["1password.desktop"];
      };

    defaultApplications =
      {
        # Directory Browser
        "inode/directory" = [defaultFileBrowser];

        # Web Browser
        "x-scheme-handler/http" = [defaultBrowser];
        "x-scheme-handler/https" = [defaultBrowser];
        "application/xhtml+xml" = [defaultBrowser];
        "text/html" = [defaultBrowser];
        "text/xml" = [defaultBrowser];

        # PDFs
        "application/pdf" = ["org.gnome.Papers.desktop"];

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
        "application/x-modrinth-modpack+zip" = ["org.gnome.FileRoller.desktop"];
      }
      // lib.optionalAttrs nixosConfig.programs._1password-gui.enable {
        "x-scheme-handler/onepassword" = ["1password.desktop"];
      };
  };
}
