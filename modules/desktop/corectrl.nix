{
  config,
  lib,
  ...
}: {
  programs.corectrl.enable = lib.mkDefault true;
  # https://gitlab.com/corectrl/corectrl/-/wikis/Setup#full-amd-gpu-controls
  hardware.amdgpu.overdrive.enable = lib.mkDefault config.programs.corectrl.enable;
}
