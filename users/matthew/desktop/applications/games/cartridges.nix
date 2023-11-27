{pkgs, ...}: {
  home.packages = with pkgs; [cartridges];
}
