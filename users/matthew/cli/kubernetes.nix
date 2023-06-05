{
  config,
  flavour,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [kubernetes kubernetes-helm kubelogin-oidc];

  # Change the kubeconfig location
  home.sessionVariables.KUBECONFIG = "${config.home.homeDirectory}/.config/kubernetes/config.yaml";

  # Enable k9s.
  programs.k9s.enable = true;

  # Enable the catppuccin theme for k9s
  xdg.configFile."k9s/skin.yml".source = "${pkgs.catppuccin-k9s}/${flavour}.yaml";
}
