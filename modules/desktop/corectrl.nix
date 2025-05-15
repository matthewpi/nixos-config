{lib, ...}: {
  programs.corectrl = {
    enable = lib.mkDefault true;
    # https://gitlab.com/corectrl/corectrl/-/wikis/Setup#full-amd-gpu-controls
    gpuOverclock.enable = lib.mkDefault true;
  };
}
