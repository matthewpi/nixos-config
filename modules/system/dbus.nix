{lib, ...}: {
  # Use the faster dbus-broker instead of the classic dbus-daemon.
  services.dbus.implementation = lib.mkDefault "broker";
}
