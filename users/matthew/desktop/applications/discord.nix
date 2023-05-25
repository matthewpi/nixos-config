{pkgs, ...}: {
  home.packages = with pkgs; [discord-canary];

  # For whatever reason the default StartupWMClass is set incorrectly, causing duplicate icons
  # to appear in the taskbar.
  xdg.desktopEntries.discord-canary = {
    categories = ["Network" "InstantMessaging"];
    exec = "DiscordCanary";
    genericName = "All-in-one cross-platform voice and text chat for gamers";
    icon = "discord-canary";
    mimeType = ["x-scheme-handler/discord"];
    name = "Discord Canary";
    settings = {
      StartupWMClass = "discord";
    };
  };
}
