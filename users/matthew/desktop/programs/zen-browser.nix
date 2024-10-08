{inputs, ...}: let
  modulePath = ["programs" "zen-browser"];
  mkFirefoxModule = import "${inputs.home-manager}/modules/programs/firefox/mkFirefoxModule.nix";
in {
  meta.maintainers = [];

  imports = [
    (mkFirefoxModule {
      inherit modulePath;
      name = "Zen Browser";
      wrappedPackageName = "zen-browser";
      unwrappedPackageName = "zen-browser-unwrapped";
      visible = true;

      platforms.linux = rec {
        vendorPath = ".zen";
        configPath = vendorPath;
      };

      platforms.darwin = {
        vendorPath = "Library/Application Support/Mozilla"; # TODO
        configPath = "Library/Application Support/Firefox"; # TODO
      };
    })
  ];
}
