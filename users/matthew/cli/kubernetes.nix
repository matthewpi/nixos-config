{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [kubectl kubernetes-helm];

  # Change the default kubeconfig location.
  home.sessionVariables.KUBECONFIG = "${config.home.homeDirectory}/.config/kubernetes/config.yaml";

  # Enable k9s.
  programs.k9s.enable = true;
}
