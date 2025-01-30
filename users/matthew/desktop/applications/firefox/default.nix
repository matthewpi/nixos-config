{
  inputs,
  isDesktop,
  lib,
  pkgs,
  ...
}: {
  home.sessionVariables.BROWSER = "firefox";

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    # Configure the default Firefox profile.
    profiles.default = lib.mkIf (!isDesktop) {
      extensions = let
        # While the flake directly outputs packages, it does so using it's own
        # nixpkgs instance which doesn't have `allowUnfree` enabled, which is
        # necessary for us to be able to use `night-eye-dark-mode` and
        # `onepassword-password-manager`.
        addons = import "${inputs.firefox-addons}/default.nix" {inherit (pkgs) fetchurl lib stdenv;};
      in
        with addons; [
          decentraleyes
          no-pdf-download
          onepassword-password-manager
          stylus
          temporary-containers
          ublock-origin
          # react-devtools
          # vue-js-devtools

          # Catppuccin Selector
          (buildFirefoxXpiAddon {
            pname = "catppuccin-selector";
            version = "1.1";
            addonId = "catppuccin@federicoscodelaro.com";
            url = "https://addons.mozilla.org/firefox/downloads/file/4279013/catppuccin_selector-1.1.xpi";
            sha256 = "sha256-fuBLp4z7SQbRV67mO3015W3YucrM6xQfts9Un1lPODY=";
            meta = {
              homepage = "https://github.com/pudymody/firefox-catppuccin";
              description = "Soothing pastel themes for Firefox";
              license = lib.licenses.mit;
              mozPermissions = [];
              platforms = lib.platforms.all;
            };
          })

          # Dark Mode - Night Eye
          (buildFirefoxXpiAddon {
            pname = "night-eye-dark-mode";
            version = "5.2.3";
            addonId = "{7c6d56ed-2616-48f2-bfde-d1830f1cf2ed}";
            url = "https://addons.mozilla.org/firefox/downloads/file/4367130/night_eye_dark_mode-5.2.3.xpi";
            sha256 = "sha256-AQu4VTsO+GlWdaSytzCebY7QjVUkmRWms3SN7fTn6ew=";
            meta = {
              homepage = "https://nighteye.app/";
              description = "Dark Mode on nearly all websites, improving readability and reducing eye strain in low light environments";
              license = lib.licenses.unfree;
              # mozPermissions = [];
              platforms = lib.platforms.all;
            };
          })

          # Disable WebRTC
          (buildFirefoxXpiAddon {
            pname = "happy-bonobo-disable-webrtc";
            version = "1.0.23";
            addonId = "jid1-5Fs7iTLscUaZBgwr@jetpack";
            url = "https://addons.mozilla.org/firefox/downloads/file/3551985/happy_bonobo_disable_webrtc-1.0.23.xpi";
            sha256 = "sha256-sUTzAyoJiMAYUUbfWgNQgYGzsiz9JqP2xNEy4viD5Ps=";
            meta = {
              homepage = "https://github.com/ChrisAntaki/disable-webrtc-firefox";
              description = "";
              license = lib.licenses.mpl20;
              # mozPermissions = [];
              platforms = lib.platforms.all;
            };
          })
        ];

      bookmarks = {};

      containersForce = true;
      containers = {
        personal = {
          id = 1;
          color = "blue";
          icon = "fingerprint";
          name = "Personal";
        };

        work = {
          id = 2;
          color = "yellow";
          icon = "briefcase";
          name = "Work";
        };

        rock = {
          id = 3;
          color = "green";
          icon = "tree";
          name = "Rock";
        };
      };

      search = {
        default = "Brave";
        privateDefault = "Brave";
        order = ["Brave"];
        force = true;

        engines = {
          "Brave" = {
            urls = [
              {
                template = "https://search.brave.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${./brave-search-icon.svg}";
            definedAliases = ["@brave"];
          };

          "BGP.Tools" = {
            urls = [
              {
                template = "https://bgp.tools/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${./bgp-tools.ico}";
            definedAliases = ["@bgp"];
          };

          "MDN Web Docs" = {
            urls = [
              {
                template = "https://developer.mozilla.org/en-US/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${./mdn.svg}";
            definedAliases = ["@mdn"];
          };

          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@nix"];
          };

          "Go Packages" = {
            urls = [
              {
                template = "https://pkg.go.dev/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            # iconUpdateURL = "https://pkg.go.dev/favicon.ico";
            # updateInterval = 24 * 60 * 60 * 1000; # every day
            icon = "${./go.ico}";
            definedAliases = ["@go"];
          };

          "Simple Icons" = {
            urls = [
              {
                template = "https://simpleicons.org";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${./simpleicons.svg}";
            definedAliases = ["@go"];
          };

          "Bing".metaData.hidden = true;
          "DuckDuckGo".metaData.hidden = true;
          "eBay".metaData.hidden = true;
          "Wikipedia (en)".metaData.hidden = true;
        };
      };

      settings = {
        "browser.download.useDownloadDir" = false;
        "browser.search.region" = "CA";
        "browser.startup.homepage" = "chrome://browser/content/blanktab.html";

        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;

        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        "mousebutton.4th.enabled" = false;
        "mousebutton.5th.enabled" = false;

        "network.dns.disablePrefetch" = true;
        "network.dns.echconfig.enabled" = true;
        "network.predictor.enabled" = false;
        "network.prefetch-next" = false;

        # "network.trr.custom_uri" = "";
        "network.trr.mode" = 2;
        # "network.trr.uri" = "";

        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.shell.didSkipDefaultBrowserCheckOnFirstRun" = true;

        "app.normandy.first_run" = false;

        "browser.toolbars.bookmarks.visibility" = "never";

        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.enabled" = false;
        "browser.protections_panel.infoMessage.seen" = true;
        "browser.translations.panelShown" = true;

        "browser.warnOnQuitShortcut" = false;

        "datareporting.healthreport.uploadEnabled" = false;

        "font.name.serif.x-western" = "Inter";
      };
    };
  };
}
