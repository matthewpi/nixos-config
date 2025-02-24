{pkgs, ...}: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./bottom.nix
    ./direnv.nix
    ./eza.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./kanidm.nix
    ./kubernetes.nix
    ./man.nix
    ./neovim.nix
    ./nix-index.nix
    ./nodejs.nix
    ./ripgrep.nix
    ./ssh.nix
    ./starship.nix
    ./step.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    attic-client
    bgpq4
    gnmic
    jq
    nix-output-monitor
    numbat
    whois
    yq-go
  ];

  home.shell = {
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableIonIntegration = false;
    enableNushellIntegration = false;
    enableShellIntegration = true;
    enableZshIntegration = true;
  };
}
