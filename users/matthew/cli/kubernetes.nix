{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    kubectl
    kubelogin-oidc
    kubernetes-helm
  ];

  # Change the default kubeconfig location.
  home.sessionVariables.KUBECONFIG = "${config.xdg.configHome}/kubernetes/config.yaml";

  # Enable k9s.
  programs.k9s.enable = true;

  # Configure a `kuberc` configuration for kubectl.
  home.sessionVariables.KUBERC = "${config.xdg.configHome}/kubernetes/kuberc.yaml";
  home.file.".kube/kubrc".source = config.xdg.configFile."kubernetes/kuberc.yaml".source;
  xdg.configFile."kubernetes/kuberc.yaml".source = (pkgs.formats.yaml {}).generate "kuberc.yaml" {
    apiVersion = "kubectl.config.k8s.io/v1beta1";
    kind = "Preference";

    # Only allow certain credential plugins.
    credentialPluginPolicy = "Allowlist";
    credentialPluginAllowlist = [
      {
        name = lib.getExe pkgs.kubelogin-oidc;
      }
      {
        name = "/etc/profiles/per-user/${config.home.username}/bin/kubectl";
      }
    ];

    # Configure defaults for some commands.
    defaults = [
      # Use server-side apply by default.
      {
        command = "apply";
        options = [
          {
            name = "server-side";
            default = "true";
          }
        ];
      }
    ];
  };
}
