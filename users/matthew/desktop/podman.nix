{
  services.podman = {
    enable = true;

    # Allow some insecure registries to be used.
    # registries.insecure = lib.mkDefault ["127.0.0.1:8790" "localhost:8790"];
  };
}
