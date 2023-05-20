{lib, ...}: {
  # Enable printing
  #
  # Once the IT industry rules the world and has successfully destroyed all printers, this should be
  # removed :)
  services.printing.enable = lib.mkDefault true;
}
