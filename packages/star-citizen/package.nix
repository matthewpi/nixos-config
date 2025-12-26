{
  # bashInteractive,
  callPackage,
  lib,
  fetchurl,
  freetype,
  makeDesktopItem,
  symlinkJoin,
  wine,
  wineprefix-preparer,
  winetricks,
  vulkan-loader,
  # general settings
  location ? "\"$HOME\"/Games/star-citizen",
  preCommands ? null,
  postCommands ? null,
  disableEac ? false,
  # caching
  enableGlCache ? true,
  glCacheSize ? 1073741824,
  # wine
  wineDllOverrides ? ["winemenubuilder.exe=d" "winex11.drv=d" "winewayland.drv=b"],
  # wineFlags ? "",
  # umu
  useUmu ? true,
  umu-launcher,
  proton-ge-bin,
}: let
  rsiLauncherSetup = let
    # Latest version can be found: https://install.robertsspaceindustries.com/rel/2/latest.yml
    version = "2.11.0";
  in
    fetchurl {
      url = "https://install.robertsspaceindustries.com/rel/2/RSI%20Launcher-Setup-${version}.exe";
      name = "RSI-Launcher-Setup-${version}.exe";
      hash = "sha256-kC+7Ne+ESy5B8I4cxBSZjgtOFAHoe8fx3iPfJi/qYY8=";
    };

  # wineCmd = "wine" + lib.optionalString (wineFlags != "") " ${wineFlags}";

  writeShellApplication = callPackage ./write-shell-application.nix {};

  script = writeShellApplication {
    name = "star-citizen";

    libraryPath = [
      freetype
      vulkan-loader
    ];
    runtimeInputs =
      if useUmu
      then [
        umu-launcher
      ]
      else [
        wine
        wineprefix-preparer
        winetricks
      ];
    runtimeEnv =
      {
        # # This fixes a .NET error when trying to run the EasyAntiCheat Setup
        # # after verifying the game files.
        # DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";

        DXVK_HDR = "1";
        DXVK_NVAPIHACK = "0";
        DXVK_ENABLE_NVAPI = "0";

        # Show in the HUD when DXVK is compiling shaders (appears as white-text in the bottom left of the game window).
        DXVK_HUD = "compiler";
      }
      // lib.optionalAttrs useUmu {
        GAMEID = "umu-starcitizen";
        STORE = "none";

        PROTON_VERBS = lib.concatStringsSep "," ["waitforexitandrun"];
        PROTONPATH = "${proton-ge-bin.steamcompattool}/";

        PROTON_ENABLE_WAYLAND = "1";
        PROTON_ENABLE_WOW64 = "1";
      }
      // lib.optionalAttrs (!useUmu) {
        # WINE_BIN = lib.getExe wine;
        WINEARCH = "win64";
        WINEDEBUG = "-all";
        WINEFSYNC = "0";
        WINEESYNC = "0";
        WINEDLLOVERRIDES = lib.concatStringsSep ";" wineDllOverrides;
        WINETRICKS_LATEST_VERSION_CHECK = "disabled";
      }
      // lib.optionalAttrs enableGlCache {
        # MESA (Intel and AMD)
        MESA_SHADER_CACHE_MAX_SIZE = "${builtins.toString (builtins.floor (glCacheSize / 1024 / 1024 / 1024))}G";

        # NVIDIA
        __GL_SHADER_DISK_CACHE = "1";
        __GL_SHADER_DISK_CACHE_SIZE = builtins.toString glCacheSize;
        __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
      }
      // lib.optionalAttrs disableEac {
        EOS_USE_ANTICHEATCLIENTNULL = "1";
      };

    # runtimeEnvLiteral is like runtimeEnv except that all variables here are
    # placed after `runtimeEnv` and the values are **NOT** escaped using `lib.escapeShellArg`.
    #
    # Only values that are properly escaped should be placed here.
    runtimeEnvLiteral =
      {
        # TODO: should we move this back into the script, it doesn't need to be exported.
        RSI_LAUNCHER = "\"$WINEPREFIX\"'/drive_c/Program Files/Roberts Space Industries/RSI Launcher/RSI Launcher.exe'";
      }
      // lib.optionalAttrs enableGlCache {
        # MESA (Intel and AMD)
        MESA_SHADER_CACHE_DIR = "\"$WINEPREFIX\"";

        # NVIDIA
        __GL_SHADER_DISK_CACHE_PATH = "\"$WINEPREFIX\"";
      };

    # TODO: remove
    checkPhase = ":";

    preText = ''
      # Ensure the prefix path exists and ensure WINEPREFIX is resolved to the
      # actual path if `location` is (or is under) a symlink.
      mkdir -p ${location}
      WINEPREFIX="$(readlink -f ${location})"
      export WINEPREFIX
      echo 'Using wine prefix located at: '"$WINEPREFIX"
    '';

    # UMU
    text = ''
      if [ "${"\${1:-}"}" = '--remove-eac' ]; then
        echo 'Removing Easy Anti-Cheat files...'
        rm -rf "$WINEPREFIX"'/drive_c/users/matthew/AppData/Roaming/EasyAntiCheat'
        rm -rf "$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/StarCitizen/LIVE/EasyAntiCheat'
        rm -rf "$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/StarCitizen/PTU/EasyAntiCheat'
        exit 0
      fi

      # Ensure RSI Launcher is installed.
      if [ ! -e "$RSI_LAUNCHER" ]; then
        # Run the installer silently.
        echo 'RSI Launcher not found, running installer...'
        umu-run ${rsiLauncherSetup} /S
        echo 'RSI Launcher installed!'
      fi

      ${lib.optionalString (preCommands != null) preCommands}
      umu-run "$RSI_LAUNCHER" "$@"
      ${lib.optionalString (postCommands != null) postCommands}
    '';

    # text = ''
    #   if [ "${"\${1:-}"}" = '--remove-eac' ]; then
    #     echo 'Removing Easy Anti-Cheat files...'
    #     rm -rf "$WINEPREFIX"'/drive_c/users/matthew/AppData/Roaming/EasyAntiCheat'
    #     rm -rf "$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/StarCitizen/LIVE/EasyAntiCheat'
    #     rm -rf "$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/StarCitizen/PTU/EasyAntiCheat'
    #     exit 0
    #   fi

    #   # Ensure the "$WINEPREFIX" is setup and up-to-date with the version
    #   # of Wine we are using.
    #   wineprefix-preparer

    #   # Update the registry all at once instead of running a bunch of
    #   # `wine reg add` commands which each take a few seconds to run each.
    #   echo 'Editing registry...'
    #   wine regedit ${./star-citizen.reg}

    #   # Ensure the necessary winetricks are installed.
    #   #
    #   # NOTE: this was designed for speed on existing installs, hence why
    #   # we run `winetricks list-installed` once and only refresh it if a
    #   # trick was installed. Keep in mind a installing a trick may install
    #   # multiple, so we need to keep `installedTricks` updated.
    #   tricksInstalled=0
    #   installedTricks="$(winetricks list-installed)"
    #   for trick in powershell corefonts tahoma; do
    #     if ! echo "$installedTricks" | grep -qw "$trick"; then
    #       echo 'winetricks: installing '"$trick"'...'
    #       winetricks -q -f "$trick"
    #       tricksInstalled=1

    #       # Everytime we install a trick, refresh `installedTricks`. Running
    #       # `winetricks list-installed` is quite slow, so on an existing
    #       # install, we only want to run it once.
    #       installedTricks="$(winetricks list-installed)"
    #     else
    #       echo 'winetricks: '"$trick"' is already installed'
    #     fi
    #   done

    #   # If tricks were installed, restart the `wineserver`.
    #   if [ "$tricksInstalled" -eq 1 ]; then
    #     echo 'Stopping wineserver since tricks were installed...'
    #     wineserver --kill
    #   fi

    #   # Ensure RSI Launcher is installed.
    #   if [ ! -e "$RSI_LAUNCHER" ]; then
    #     # Run the installer silently.
    #     echo 'RSI Launcher not found, running installer...'
    #     WINEDLLOVERRIDES='dxwebsetup.exe,dotNetFx45_Full_setup.exe,'"$WINEDLLOVERRIDES" wine ${rsiLauncherSetup} /S
    #     echo 'RSI Launcher installed!'

    #     # Stop wineserver after the installer exits to ensure it gets
    #     # restarted before starting the Launcher.
    #     wineserver --kill
    #   fi

    #   # Ensure the required directories for Star Citizen already exist, these
    #   # directories are were the game files will be installed to.
    #   mkdir -p "$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/StarCitizen/'{LIVE,PTU}

    #   # Enter the prefix's directory.
    #   cd "$WINEPREFIX"

    #   # Allow entering a shell, this is useful to execute wine commands, such as
    #   # `winecfg` or `wine reg add`.
    #   if [ "${"\${1:-}"}" = '--shell' ]; then
    #     echo 'Entered shell for star-citizen'
    #     exec ${lib.getExe bashInteractive}
    #   fi

    #   ${lib.optionalString (preCommands != null) preCommands}
    #   # Start the RSI Launcher.
    #   if [[ -t 1 ]]; then
    #     ${wineCmd} "$RSI_LAUNCHER" "$@"
    #   else
    #     LOG_DIR="$(mktemp -d)"
    #     ${wineCmd} "$RSI_LAUNCHER" "$@" >"$LOG_DIR"/RSIout 2>"$LOG_DIR"/RSIerr
    #   fi

    #   # Block until all wine windows get closed.
    #   echo 'RSI Launcher exited, waiting for all wine windows to close...'
    #   wineserver --wait
    #   ${lib.optionalString (postCommands != null) postCommands}
    # '';
  };

  desktopItem = makeDesktopItem {
    name = "star-citizen";
    exec = "${lib.getExe script} %U";
    icon = "star-citizen";
    desktopName = "Star Citizen";
    comment = "Star Citizen";
    categories = ["Game"];
    mimeTypes = ["application/x-star-citizen-launcher"];
  };
in
  symlinkJoin {
    name = "star-citizen";
    paths = [
      script
      desktopItem
    ];

    postBuild = ''
      mkdir -p "$out"/share/icons/hicolor/scalable/apps
      ln -s ${./star-citizen.svg} "$out"/share/icons/hicolor/scalable/apps/star-citizen.svg
    '';

    passthru.script = script;

    meta = {
      mainPrograma = "star-citizen";
      description = "Star Citizen installer and launcher";
      homepage = "https://robertsspaceindustries.com/";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [matthewpi];
      platforms = ["x86_64-linux"];
    };
  }
