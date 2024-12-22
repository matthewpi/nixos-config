{
  lib,
  pkgs,
  ...
}: {
  programs.captive-browser = {
    enable = true;
    interface = "wlan0";
    browser = ''
      env XDG_CONFIG_HOME="$PREV_CONFIG_HOME" ${lib.getExe pkgs.ungoogled-chromium} --user-data-dir=''${XDG_DATA_HOME:-$HOME/.local/share}/chromium-captive --proxy-server="socks5://$PROXY" --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost" --no-first-run --new-window --incognito -no-default-browser-check http://cache.nixos.org/
    '';
  };
}
