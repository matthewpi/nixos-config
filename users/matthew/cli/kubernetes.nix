{
  flavour,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [kubernetes kubernetes-helm kubelogin-oidc];

  # Enable k9s.
  programs.k9s.enable = true;

  # Enable the catppuccin theme for k9s
  xdg.configFile."k9s/skin.yml".source = "${pkgs.catppuccin-k9s}/${flavour}.yaml";
}
