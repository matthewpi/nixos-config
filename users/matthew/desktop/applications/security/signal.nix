{
  lib,
  pkgs,
  ...
}: {
  # For whatever reason the default StartupWMClass is set incorrectly, causing duplicate icons
  # to appear in the taskbar.
  xdg.desktopEntries.signal-desktop = {
    categories = ["Network" "InstantMessaging" "Chat"];
    comment = "Private messaging from your desktop";
    exec = "${lib.getExe' pkgs.signal-desktop "signal-desktop"} --no-sandbox %U";
    icon = "signal-desktop";
    mimeType = ["x-scheme-handler/sgnl" "x-scheme-handler/signalcaptcha"];
    name = "Signal";
    settings.StartupWMClass = "signal";
  };

  home.packages = with pkgs; [signal-desktop];
}
