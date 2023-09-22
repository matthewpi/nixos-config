{pkgs, ...}: {
  home.packages = with pkgs; [
    jetbrains-toolbox

    jetbrains-datagrip
    jetbrains-goland
    jetbrains-idea-ultimate
    jetbrains-phpstorm
    jetbrains-webstorm
  ];
}
