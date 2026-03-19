{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.ghostty-bin.terminfo];

  environment.pathsToLink = ["/share/terminfo"];
  environment.etc.terminfo.source = "${config.system.path}/share/terminfo";
  # TODO: use `environment.profileRelativeSessionVariables`
  environment.variables.TERMINFO_DIRS = map (path: path + "/share/terminfo") config.environment.profiles ++ ["/usr/share/terminfo"];

  security.sudo.extraConfig = lib.mkIf config.security.sudo.keepTerminfo ''

    # Keep terminfo database for root and %admin.
    Defaults:root,%admin env_keep+=TERMINFO_DIRS
    Defaults:root,%admin env_keep+=TERMINFO
  '';

  # environment.extraInit = ''
  #   # Reset TERM with new TERMINFO available (if any)
  #   export TERM="$TERM"
  # '';
}
