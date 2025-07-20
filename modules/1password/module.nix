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

    finalPackage = lib.mkOption {
      type = lib.types.package;
      visible = false;
      readOnly = true;
    };

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
    programs._1password-gui.finalPackage = cfg.package.override {inherit (cfg) polkitPolicyOwners;};

    environment.systemPackages = [cfg.finalPackage];
    users.groups.onepassword.gid = config.ids.gids.onepassword;

    security.wrappers."1Password-BrowserSupport" = {
      source = "${cfg.finalPackage}/share/1password/1Password-BrowserSupport";
      owner = "root";
      group = "onepassword";
      setuid = false;
      setgid = true;
    };
  };
}
