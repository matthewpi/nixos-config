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
          # 7tv
          decentraleyes
          # hoppscotch
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
            iconUpdateURL = "https://cdn.search.brave.com/serp/v2/_app/immutable/assets/brave-search-icon.CsIFM2aN.svg";
            updateInterval = 24 * 60 * 60 * 1000; # every day
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
            iconUpdateURL = "https://bgp.tools/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@bgp"];
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
            iconUpdateURL = "https://pkg.go.dev/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000; # every day
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

        "extensions.activeThemeID" = "{1cd0d6ef-d4bf-4fd1-9d80-4a9811a84647}";
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

        # "browser.uiCustomization.state" = ''
        #   {"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["_7cc17731-b734-4c98-a154-51d2bf266ef4_-browser-action","_7ef0f00c-2ebe-4626-8ed7-3185847fcfad_-browser-action","ublock0_raymondhill_net-browser-action","jid1-5fs7itlscuazbgwr_jetpack-browser-action","jid1-bofifl9vbdl2zq_jetpack-browser-action","_5caff8cc-3d2e-4110-a88a-003cc85b3858_-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","customizableui-special-spring1","urlbar-container","customizableui-special-spring2","downloads-button","bookmarks-menu-button","developer-button","_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action","_25fc87fa-4d31-4fee-b5c1-c32a7844c063_-browser-action","_7c6d56ed-2616-48f2-bfde-d1830f1cf2ed_-browser-action","unified-extensions-button","78272b6fa58f4a1abaac99321d503a20_proton_me-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","_25fc87fa-4d31-4fee-b5c1-c32a7844c063_-browser-action","ublock0_raymondhill_net-browser-action","jid1-5fs7itlscuazbgwr_jetpack-browser-action","jid1-bofifl9vbdl2zq_jetpack-browser-action","_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action","_7ef0f00c-2ebe-4626-8ed7-3185847fcfad_-browser-action","_7cc17731-b734-4c98-a154-51d2bf266ef4_-browser-action","_5caff8cc-3d2e-4110-a88a-003cc85b3858_-browser-action","_7c6d56ed-2616-48f2-bfde-d1830f1cf2ed_-browser-action","78272b6fa58f4a1abaac99321d503a20_proton_me-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","unified-extensions-area"],"currentVersion":19,"newElementCount":7}
        # '';

        "browser.warnOnQuitShortcut" = false;

        "datareporting.healthreport.uploadEnabled" = false;

        # "devtools.everOpened" = true;

        "font.name.serif.x-western" = "Inter";
      };
    };
  };
}
