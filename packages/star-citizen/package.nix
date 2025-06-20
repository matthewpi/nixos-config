{
  bashInteractive,
  callPackage,
  lib,
  fetchurl,
  freetype,
  makeDesktopItem,
  runCommand,
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
  # umu-launcher
  useUmu ? false,
  umu-launcher,
  proton-ge-bin,
  protonPath ? "${proton-ge-bin.steamcompattool}/",
  protonVerbs ? ["waitforexitandrun"],
  # wine
  wineDllOverrides ? ["winemenubuilder.exe=d"],
  wineFlags ? "",
}: let
  # Latest version can be found: https://install.robertsspaceindustries.com/rel/2/latest.yml
  version = "2.4.0";

  src = fetchurl {
    url = "https://install.robertsspaceindustries.com/rel/2/RSI%20Launcher-Setup-${version}.exe";
    name = "RSI Launcher-Setup-${version}.exe";
    hash = "sha256-2/0ZRJaV6IXVTZGNmrgm1RqOBUdzqQukKwcjyOdmYQA=";
  };

  wineCmd = "wine${lib.optionalString (wineFlags != "") " ${wineFlags}"}";

  writeShellApplication = callPackage ./write-shell-application.nix {};

  script = writeShellApplication {
    name = "star-citizen";

    libraryPath = [freetype vulkan-loader];
    runtimeInputs =
      if useUmu
      then [umu-launcher]
      else [wine wineprefix-preparer winetricks];
    runtimeEnv =
      {
        WINETRICKS_LATEST_VERSION_CHECK = "disabled";
        WINEARCH = "win64";

        DXVK_HDR = "1";

        # PROTON_ENABLE_WAYLAND = "1";
        # PROTON_ENABLE_HDR = "1";
        DISPLAY = ""; # TODO: remove
      }
      // lib.optionalAttrs enableGlCache {
        # MESA (Intel and AMD)
        MESA_SHADER_CACHE_MAX_SIZE = "${builtins.toString (builtins.floor (glCacheSize / 1024 / 1024 / 1024))}G";

        # NVIDIA
        __GL_SHADER_DISK_CACHE = "1";
        __GL_SHADER_DISK_CACHE_SIZE = builtins.toString glCacheSize;
        __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";

        # TODO: document
        DXVK_ENABLE_NVAPI = "1";
      }
      // lib.optionalAttrs useUmu {
        GAMEID = "umu-starcitizen";
        STORE = "none";

        PROTON_VERBS = lib.concatStringsSep "," protonVerbs;
        PROTONPATH = protonPath;
      }
      // lib.optionalAttrs (!useUmu) {
        WINEDEBUG = "-all";
        WINEFSYNC = "1";
        WINEESYNC = "1";
        WINEDLLOVERRIDES = lib.concatStringsSep ";" wineDllOverrides;
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
      echo "$WINEPREFIX"
    '';

    text =
      (
        if useUmu
        then ''
          # Ensure RSI Launcher is installed.
          if [ ! -e "$RSI_LAUNCHER" ]; then
            # Run the installer silently.
            echo 'RSI Launcher not found, running installer...'
            umu-run "${src}" /S
            echo 'RSI Launcher installed!'
          fi
        ''
        else ''
          # Ensure the "$WINEPREFIX" is setup and up-to-date with the version
          # of Wine we are using.
          wineprefix-preparer

          # Update the registry all at once instead of running a bunch of
          # `wine reg add` commands which each take a few seconds to run each.
          echo 'Editing registry...'
          wine regedit ${./star-citizen.reg}

          # Ensure the necessary winetricks are installed.
          #
          # NOTE: this was designed for speed on existing installs, hence why
          # we run `winetricks list-installed` once and only refresh it if a
          # trick was installed. Keep in mind a installing a trick may install
          # multiple, so we need to keep `installedTricks` updated.
          tricksInstalled=0
          installedTricks="$(winetricks list-installed)"
          for trick in powershell corefonts tahoma; do
            if ! echo "$installedTricks" | grep -qw "$trick"; then
              echo 'winetricks: installing '"$trick"'...'
              winetricks -q -f "$trick"
              tricksInstalled=1

              # Everytime we install a trick, refresh `installedTricks`. Running
              # `winetricks list-installed` is quite slow, so on an existing
              # install, we only want to run it once.
              installedTricks="$(winetricks list-installed)"
            else
              echo 'winetricks: '"$trick"' is already installed'
            fi
          done

          # If tricks were installed, restart the `wineserver`.
          if [ "$tricksInstalled" -eq 1 ]; then
            echo 'Stopping wineserver after tricks were installed...'
            wineserver --kill
          fi

          # Ensure RSI Launcher is installed.
          if [ ! -e "$RSI_LAUNCHER" ]; then
            # Run the installer silently.
            echo 'RSI Launcher not found, running installer...'
            WINEDLLOVERRIDES='dxwebsetup.exe,dotNetFx45_Full_setup.exe,winemenubuilder.exe=d' wine ${src} /S
            echo 'RSI Launcher installed!'

            # Stop wineserver after the installer exits to ensure it gets
            # restarted before starting the Launcher.
            wineserver --kill
          fi
        ''
      )
      + ''

        # Ensure the required directories for Star Citizen already exist, these
        # directories are were the game files will be installed to.
        mkdir -p "$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/StarCitizen/'{LIVE,PTU}

        # Enter the prefix's directory.
        cd "$WINEPREFIX"

        # Allow entering a shell, this is useful to execute wine commands, such as
        # `winecfg` or `wine reg add`.
        if [ "${"\${1:-}"}" = '--shell' ]; then
          echo 'Entered Shell for star-citizen'
          exec ${lib.getExe bashInteractive}
        fi

        # HACK: if we are running Wine Wayland, add the `--in-process-gpu` flag
        # to the launcher.
        if [[ "''${PROTON_ENABLE_WAYLAND:-0}" == '1' || -z "$DISPLAY" ]]; then
          echo 'Wine Wayland detected, adding --in-process-gpu flag to RSI Launcher command.'
          set -- "$@" '--in-process-gpu'
        fi

        # Only execute `mangohud` if it exists on the system.
        if command -v mangohud > /dev/null 2>&1; then
          mangohud='mangohud'
        else
          mangohud=""
        fi
      ''
      + lib.optionalString (preCommands != null) preCommands
      + (
        if useUmu
        then ''
          "$mangohud" umu-run "$RSI_LAUNCHER" "$@"
        ''
        else ''
          # Start the RSI Launcher.
          if [[ -t 1 ]]; then
            "$mangohud" ${wineCmd} "$RSI_LAUNCHER" "$@"
          else
            LOG_DIR="$(mktemp -d)"
            "$mangohud" ${wineCmd} "$RSI_LAUNCHER" "$@" >"$LOG_DIR"/RSIout 2>"$LOG_DIR"/RSIerr
          fi

          # Block until all wine windows get closed.
          echo 'RSI Launcher exited, waiting for all wine windows to close...'
          wineserver --wait
          echo 'All windows closed, exiting...'
        ''
      )
      + lib.optionalString (postCommands != null) postCommands;
  };

  icon = fetchurl {
    url = "https://logos-world.net/SVGimage/Star_Citizen_300124/Star_Citizen_(1).svg";
    name = "star-citizen.svg";
    hash = "sha256-r3Y3RTl7ZoGmGLm2tjfCtRbAtEdORByeAa2HToQtISU=";
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
      (runCommand "star-citizen-icon" {} ''
        mkdir -p "$out"/share/icons/hicolor/scalable/apps
        ln -s ${icon} "$out"/share/icons/hicolor/scalable/apps/star-citizen.svg
      '')
    ];

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
