{
  lib,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  gamemode,
  gamescope,
  winetricks,
  wine,
  dxvk,
  wineFlags ? "",
  location ? "$HOME/Games/star-citizen",
  tricks ? ["powershell" "corefonts" "tahoma"],
  wineDllOverrides ? ["winemenubuilder.exe=d"],
  gameScopeEnable ? false,
  gameScopeArgs ? [],
  preCommands ? "",
  postCommands ? "",
  enableGlCache ? true,
  glCacheSize ? 1073741824,
  pkgs,
}: let
  # Latest version can be found: https://install.robertsspaceindustries.com/rel/2/latest.yml
  version = "2.1.1";
  src = pkgs.fetchurl {
    url = "https://install.robertsspaceindustries.com/rel/2/RSI%20Launcher-Setup-${version}.exe";
    name = "RSI Launcher-Setup-${version}.exe";
    hash = "sha256-zSFrmvjHN9u/PdZUcRTUgmRGx51p9t+MSkDxB7q1sNo=";
  };

  # concat winetricks args
  tricksFmt =
    if (builtins.length tricks) > 0
    then lib.concatStringsSep " " tricks
    else "-V";

  gameScope = lib.strings.optionalString gameScopeEnable "${lib.getExe gamescope} ${lib.concatStringsSep " " gameScopeArgs} --";

  script = writeShellScriptBin "star-citizen" ''
    export WINETRICKS_LATEST_VERSION_CHECK=disabled
    export WINEARCH="win64"
    export WINEPREFIX="${location}"
    export WINEFSYNC=1
    export WINEESYNC=1
    export WINEDLLOVERRIDES="${lib.concatStringsSep "," wineDllOverrides}"

    # Anti-cheat
    export EOS_USE_ANTICHEATCLIENTNULL=1

    # Nvidia tweaks
    export WINE_HIDE_NVIDIA_GPU=1

    # AMD
    export dual_color_blend_by_location="true"
    export WINEDEBUG=-all

    export STORE="none"

    export __GL_SHADER_DISK_CACHE=${
      if enableGlCache
      then "1"
      else "0"
    }
    export __GL_SHADER_DISK_CACHE_SIZE=${toString glCacheSize}

    PATH=${lib.makeBinPath [wine winetricks]}:"$PATH"
    USER="$(whoami)"
    RSI_LAUNCHER="$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/RSI Launcher/RSI Launcher.exe'

    if [ ! -d "$WINEPREFIX" ]; then
      # install tricks
      winetricks -q -f ${tricksFmt}
      wineserver -k

      mkdir -p "$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/StarCitizen/'{LIVE,PTU}

      # install launcher
      # Use silent install
      wine ${src} /S

      wineserver -k
    fi

    # TODO: find a way to make this run faster and only when needed, like if DXVK
    # is updated.
    #
    # Right now this delays the startup by 15-30 seconds.
    ${dxvk}/bin/setup_dxvk.sh install --symlink

    # EAC Fix
    if [ -d "$WINEPREFIX"/drive_c/users/"$USER"/AppData/Roaming/EasyAntiCheat ]; then
      rm -rf "$WINEPREFIX"/drive_c/users/"$USER"/AppData/Roaming/EasyAntiCheat
    fi

    cd "$WINEPREFIX"

    # wine reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v NoTrayItemsDisplay /t REG_DWORD /d 1

    ${preCommands}

    if [[ -t 1 ]]; then
        ${gameScope} ${gamemode}/bin/gamemoderun wine ${wineFlags} "$RSI_LAUNCHER" --in-process-gpu "$@"
    else
        export LOG_DIR="$(mktemp -d)"
        echo 'Working around known launcher error by outputting logs to '"$LOG_DIR"
        ${gameScope} ${gamemode}/bin/gamemoderun wine ${wineFlags} "$RSI_LAUNCHER" --in-process-gpu "$@" >"$LOG_DIR"/RSIout 2>"$LOG_DIR"/RSIerr
    fi

    wineserver -w

    ${postCommands}
  '';

  icon = pkgs.fetchurl {
    # Source: https://lutris.net/games/icon/star-citizen.png
    url = "https://github-production-user-asset-6210df.s3.amazonaws.com/17859309/255031314-2fac3a8d-a927-4aa9-a9ad-1c3e14466c20.png";
    hash = "sha256-19A1DyLQQcXQvVi8vW/ml+epF3WRlU5jTmI4nBaARF0=";
  };

  desktopItems = makeDesktopItem {
    name = "star-citizen";
    exec = "${lib.getExe script} %U";
    inherit icon;
    comment = "Star Citizen - Alpha";
    desktopName = "Star Citizen";
    categories = ["Game"];
    mimeTypes = ["application/x-star-citizen-launcher"];
  };
in
  symlinkJoin {
    name = "star-citizen";
    paths = [
      desktopItems
      script
    ];

    meta = {
      description = "Star Citizen installer and launcher";
      homepage = "https://robertsspaceindustries.com/";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [matthewpi];
      platforms = ["x86_64-linux"];
    };
  }
