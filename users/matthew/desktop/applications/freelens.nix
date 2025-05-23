{pkgs, ...}: {
  home.packages = with pkgs; [
    freelens

    # Needed by `freelens-multi-pod-logs`.
    stern
  ];
}
