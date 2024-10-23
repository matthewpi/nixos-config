{
  imports = [
    ./djt.nix
  ];

  nix = {
    distributedBuilds = true;

    # Useful when the builder has a faster internet connection than yours
    extraOptions = ''
      builders-use-substitutes = true
    '';

    settings.trusted-public-keys = [
      "matthew:bksfYGakhp4kMjdsIBHgFjMOs2ZlQ9pTLbZBvB9xxls="
      "nexavo:2x9ldvAf7+m2kRtZjGHHwwqJCNArPLuBWOJBq8lHwbc="
      "djt.nxpkgs.dev-1:IPbZL4PYlQ99i9GKE+ZN6IhK/NlLZJw0wBVVweipaOI"
      # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    settings.trusted-substituters = [
      "https://attic.nicetry.lol/matthew"
      "https://attic.nicetry.lol/nexavo"
    ];
  };
}
