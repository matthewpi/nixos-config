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
  # tricks ? ["powershell" "corefonts" "tahoma"],
}: let
  # Latest version can be found: https://install.robertsspaceindustries.com/rel/2/latest.yml
  version = "2.4.0";

  src = fetchurl {
    url = "https://install.robertsspaceindustries.com/rel/2/RSI%20Launcher-Setup-${version}.exe";
    name = "RSI Launcher-Setup-${version}.exe";
    hash = "sha256-2/0ZRJaV6IXVTZGNmrgm1RqOBUdzqQukKwcjyOdmYQA=";
  };

  writeShellApplication = callPackage ./builder.nix {};

  script = writeShellApplication {
    name = "star-citizen";

    libraryPath = [freetype vulkan-loader];
    runtimeInputs =
      if useUmu
      then [umu-launcher]
      else [wine winetricks];
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

    # NOTE: on a fresh prefix creation we will need to change the DPI if scaling
    # is enabled.
    #
    # The default DPI is 96, so for a scaling factor of 1.5, you would need to
    # change the DPI to 144 (96 * 1.5).  The DPI can be changed via running and
    # using the `winecfg` window to change the DPI.
    #
    # ```bash
    # star-citizen --shell
    # winecfg
    # ```
    #
    # TODO: automatically run `wine reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v NoTrayItemsDisplay /t REG_DWORD /d 1`
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
          # # Ensure the "$WINEPREFIX" is setup.
          # ${lib.getExe wineprefix-preparer}

          # # Ensure all tricks are installed.
          # ''${lib.toShellVars {
          #   inherit tricks;
          #   tricksInstalled = 1;
          # }}
          # for trick in "${"\${tricks[@]}"}"; do
          #   if ! winetricks list-installed | grep -qw "$trick"; then
          #     echo 'winetricks: Installing '"$trick"
          #     winetricks -q -f "$trick"
          #     tricksInstalled=0
          #   fi
          # done

          # # If tricks were installed, restart the `wineserver`.
          # if [ "$tricksInstalled" -eq 0 ]; then
          #   wineserver --kill
          # fi

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
          "$mangohud" wine${
            if (wineFlags != "")
            then " ${wineFlags}"
            else ""
          } "$RSI_LAUNCHER" "$@"

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
