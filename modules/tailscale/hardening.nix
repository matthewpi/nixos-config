{
  config,
  lib,
  ...
}: {
  # If Tailscale is enabled, configure hardening for it.
  # ref; https://tailscale.com/kb/1279/security-node-hardening#sandboxing-the-tailscale-process-on-each-system
  config = lib.mkIf config.services.tailscale.enable {
    # As of 2024-07-19 this UID and GID were unused in nixpkgs.
    ids.uids.tailscaled = 327;
    ids.gids.tailscaled = 327;
    users.users.tailscaled = {
      uid = config.ids.uids.tailscaled;
      description = "Tailscaled user";
      group = "tailscaled";
      createHome = false;
    };
    users.groups.tailscaled.gid = config.ids.gids.tailscaled;

    # Add a polkit policy allowing the tailscaled user to access systemd-resolved over dbus.
    environment.etc."polkit-1/rules.d/10-tailscaled.rules".text = lib.mkIf config.services.resolved.enable ''
      // Allow tailscaled to manipulate DNS settings]
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("org.freedesktop.resolve1.") !== 0) {
          return polkit.Result.NOT_HANDLED;
        }
        if (subject.user !== "tailscaled") {
          return polkit.Result.NOT_HANDLED;
        }
        return polkit.Result.YES;
      });
    '';

    systemd.services.tailscaled.serviceConfig = {
      User = "tailscaled";
      Group = "tailscaled";
    };
  };
}
