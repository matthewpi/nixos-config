{pkgs, ...}: {
  home.packages = with pkgs; [kubernetes kubernetes-helm];

  # TODO: catppuccin theme.  k9s uses YAML for themes which Nix doesn't provide a way to parse.
  programs.k9s.enable = true;
}
