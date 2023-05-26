{pkgs, ...}: {
  home.packages = with pkgs; [
    jetbrains-toolbox

    jetbrains.datagrip
    jetbrains-goland # TODO: rename back to `jetbrains.goland` once https://github.com/NixOS/nixpkgs/pull/234267 is merged
    jetbrains.idea-ultimate
    jetbrains.phpstorm
    jetbrains.webstorm
  ];
}
