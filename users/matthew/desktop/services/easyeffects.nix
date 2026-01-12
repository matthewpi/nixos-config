{
  # isDesktop,
  ...
}: {
  # If we aren't on the desktop, enable the EasyEffects background service,
  # this allows us to automatically apply presets without needing to manually
  # start EasyEffects on every boot.
  services.easyeffects = {
    # enable = !isDesktop;
    enable = false;
    preset = "fw16-easy-effects";
  };
}
