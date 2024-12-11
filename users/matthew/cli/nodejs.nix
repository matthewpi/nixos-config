{config, ...}: {
  home.sessionVariables.NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";

  xdg.configFile."npm/npmrc".text = ''
    # NPM
    prefix=''${XDG_DATA_HOME}/npm
    cache=''${XDG_CACHE_HOME}/npm
    init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
    tmp=''${XDG_RUNTIME_DIR}/npm

    # PNPM
    state-dir=''${XDG_STATE_HOME}/pnpm-state
    store-dir=''${XDG_DATA_HOME}/pnpm-store
  '';
}
