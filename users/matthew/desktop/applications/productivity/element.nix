{pkgs, ...}: {
  # For whatever reason the default StartupWMClass is set incorrectly, causing duplicate icons
  # to appear in the taskbar.
  xdg.desktopEntries.element-desktop = {
    categories = ["Chat" "InstantMessaging" "Network"];
    comment = "A feature-rich client for Matrix.org";
    exec = "element-desktop %F";
    genericName = "Matrix Client";
    icon = "element";
    mimeType = ["x-scheme-handler/element"];
    name = "Element";
    settings = {
      StartupWMClass = "Element";
    };
  };

  home.packages = with pkgs; [element-desktop];
}
