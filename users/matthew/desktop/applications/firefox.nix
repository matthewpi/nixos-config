{
  home.sessionVariables.BROWSER = "firefox";

  programs.firefox = {
    enable = true;

    # profiles.default = {
    #   extensions = with config.nur.repos.rycee.firefox-addons; [
    #     decentraleyes
    #     onepassword-password-manager
    #     temporary-containers
    #     ublock-origin
    #     vue-js-devtools
    #   ];

    #   search = {
    #     default = "Brave";
    #     order = ["Brave"];

    #     engines = {
    #       "Brave" = {
    #         urls = [{
    #           template = "https://search.brave.com/search";
    #           params = [
    #             { name = "q"; value = "{searchTerms}"; }
    #           ];
    #         }];

    #         icon = "";
    #         definedAliases = ["@br"];
    #       };

    #       "BGP.Tools" = {
    #         urls = [{
    #           template = "https://bgp.tools/search";
    #           params = [
    #             { name = "q"; value = "{searchTerms}"; }
    #           ];
    #         }];

    #         icon = "";
    #         definedAliases = ["@br"];
    #       };

    #       "Nix Packages" = {
    #         urls = [{
    #           template = "https://search.nixos.org/packages";
    #           params = [
    #             { name = "type"; value = "packages"; }
    #             { name = "query"; value = "{searchTerms}"; }
    #           ];
    #         }];

    #         icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    #         definedAliases = ["@np"];
    #       };
    #     };
    #   };

    #   settings = {
    #     "browser.download.useDownloadDir" = false;
    #     "browser.search.region" = "CA";
    #     "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
    #     "dom.security.https_only_mode" = true;
    #     "dom.security.https_only_mode_ever_enabled" = true;
    #     "extensions.activeThemeID" = "default-theme@mozilla.org";
    #     "extensions.formautofill.addresses.enabled" = false;
    #     "extensions.formautofill.creditCards.enabled" = false;

    #     "mousebutton.4th.enabled" = false;
    #     "mousebutton.5th.enabled" = false;

    #     "network.dns.disablePrefetch" = true;
    #     "network.dns.echconfig.enabled" = true;
    #     "network.predictor.enabled" = false;
    #     "network.prefetch-next" = false;

    #     # "network.trr.custom_uri" = "";
    #     "network.trr.mode" = 2;
    #     # "network.trr.uri" = "";

    #     "browser.bookmarks.restore_default_bookmarks" = false;
    #     "browser.shell.checkDefaultBrowser" = false;
    #     "browser.shell.defaultBrowserCheckCount" = 1;
    #     "browser.shell.didSkipDefaultBrowserCheckOnFirstRun" = true;

    #     "app.normandy.first_run" = false;

    #     "browser.toolbars.bookmarks.visibility" = "never";

    #     "browser.newtabpage.activity-stream.showSponsored" = false;
    #     "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    #     "browser.newtabpage.enabled" = false;
    #     "browser.protections_panel.infoMessage.seen" = true;
    #     "browser.translations.panelShown" = true;

    #     "browser.uiCustomization.state" = ''
    #       {"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["_7cc17731-b734-4c98-a154-51d2bf266ef4_-browser-action","_7ef0f00c-2ebe-4626-8ed7-3185847fcfad_-browser-action","ublock0_raymondhill_net-browser-action","jid1-5fs7itlscuazbgwr_jetpack-browser-action","jid1-bofifl9vbdl2zq_jetpack-browser-action","_5caff8cc-3d2e-4110-a88a-003cc85b3858_-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","customizableui-special-spring1","urlbar-container","customizableui-special-spring2","downloads-button","bookmarks-menu-button","developer-button","_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action","_25fc87fa-4d31-4fee-b5c1-c32a7844c063_-browser-action","_7c6d56ed-2616-48f2-bfde-d1830f1cf2ed_-browser-action","unified-extensions-button","78272b6fa58f4a1abaac99321d503a20_proton_me-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","_25fc87fa-4d31-4fee-b5c1-c32a7844c063_-browser-action","ublock0_raymondhill_net-browser-action","jid1-5fs7itlscuazbgwr_jetpack-browser-action","jid1-bofifl9vbdl2zq_jetpack-browser-action","_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action","_7ef0f00c-2ebe-4626-8ed7-3185847fcfad_-browser-action","_7cc17731-b734-4c98-a154-51d2bf266ef4_-browser-action","_5caff8cc-3d2e-4110-a88a-003cc85b3858_-browser-action","_7c6d56ed-2616-48f2-bfde-d1830f1cf2ed_-browser-action","78272b6fa58f4a1abaac99321d503a20_proton_me-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","unified-extensions-area"],"currentVersion":19,"newElementCount":7}
    #     '';

    #     "browser.warnOnQuitShortcut" = false;

    #     "datareporting.healthreport.uploadEnabled" = false;

    #     "devtools.everOpened" = true;

    #     "font.name.serif.x-western" = "Inter";
    #   };
    # };
  };
}
