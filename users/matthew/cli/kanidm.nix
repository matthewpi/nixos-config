{pkgs, ...}: {
  home.packages = [
    (pkgs.linkFarm "kanidm" [
      # Only add the kanidm binary to our path, not all the server ones.
      rec {
        name = "bin/kanidm";
        path = "${pkgs.kanidm}/${name}";
      }
      # Bash completions
      rec {
        name = "share/bash-completion/kanidm.bash";
        path = "${pkgs.kanidm}/${name}";
      }
      # ZSH completions
      rec {
        name = "share/zsh/site-functions/_kanidm";
        path = "${pkgs.kanidm}/${name}";
      }
    ])
  ];
}
