{pkgs, ...}: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./bottom.nix
    ./direnv.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./kubernetes.nix
    ./neovim.nix
    ./nix-index.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    jq
    whois
    yq-go

    nix-output-monitor
  ];
}
