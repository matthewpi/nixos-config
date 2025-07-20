{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs._1password-gui;
in {
  options.programs._1password-gui = {
    enable = lib.mkEnableOption "the 1Password GUI application";
    package = lib.mkPackageOption pkgs "_1password-gui" {};

    polkitPolicyOwners = lib.mkOption {
      description = ''
        A list of users who should be able to integrate 1Password with polkit-based authentication mechanisms.
      '';
      type = lib.types.listOf lib.types.str;
      default = [];
      example = lib.literalExpression ''["user1" "user2" "user3"]'';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      (pkgs.replaceVarsWith {
        name = "com.1password.1Password.policy";
        src = ./com.1password.1Password.policy;
        dir = "share/polkit-1/actions";
        replacements.policyOwners = lib.concatStringsSep " " (map (user: "unix-user:${user}") cfg.polkitPolicyOwners);
      })
    ];
    users.groups.onepassword.gid = config.ids.gids.onepassword;

    security.wrappers."1Password-BrowserSupport" = {
      source = "${cfg.package}/share/1password/1Password-BrowserSupport";
      owner = "root";
      group = "onepassword";
      setuid = false;
      setgid = true;
    };
  };
}
