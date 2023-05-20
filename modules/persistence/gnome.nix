{
  config,
  lib,
  ...
}: {
  environment.persistence."/persist".directories =
    []
    ++ lib.optionals config.services.accounts-daemon.enable ["/var/lib/AccountsService"]
    ++ lib.optionals config.services.udisks2.enable ["/var/lib/udisks2"]
    ++ lib.optionals config.services.upower.enable ["/var/lib/upower"];
}
