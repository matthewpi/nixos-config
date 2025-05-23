{
  bashInteractive,
  lib,
  fetchurl,
  freetype,
  makeDesktopItem,
  runCommand,
  symlinkJoin,
  writeShellScriptBin,
  wine,
  wineprefix-preparer,
  winetricks,
  vulkan-loader,
  wineFlags ? "",
  location ? "$HOME/Games/star-citizen",
  tricks ? ["powershell" "corefonts" "tahoma"],
  wineDllOverrides ? ["winemenubuilder.exe=d"],
  preCommands ? "",
  postCommands ? "",
  enableGlCache ? true,
  glCacheSize ? 1073741824,
}: let
  # Latest version can be found: https://install.robertsspaceindustries.com/rel/2/latest.yml
  version = "2.3.2";

  src = fetchurl {
    url = "https://install.robertsspaceindustries.com/rel/2/RSI%20Launcher-Setup-${version}.exe";
    name = "RSI Launcher-Setup-${version}.exe";
    hash = "sha256-BzsO2bHXo7axvW9enll08H5aPA1KCZSLfikE49/EUw0=";
  };

  script = writeShellScriptBin "star-citizen" ''
    # Wayland
    export DISPLAY=""
    echo "$DISPLAY"

    # Ensure the prefix path exists and ensure WINEPREFIX is resolved to the
    # actual path if `location` is (or is under) a symlink.
    mkdir -p "${location}"
    export WINEPREFIX="$(readlink -f "${location}")"
    echo "$WINEPREFIX"

    export WINETRICKS_LATEST_VERSION_CHECK=disabled
    export WINEARCH=win64
    export WINEDEBUG=-all
    export WINEFSYNC=1
    export WINEESYNC=1
    export WINEDLLOVERRIDES="${lib.concatStringsSep ";" wineDllOverrides}"

    # TODO: what is this for?
    export STORE=none

    ${lib.optionalString enableGlCache ''
      # MESA (gl cache)
      export MESA_SHADER_CACHE_DIR="$WINEPREFIX"
      export MESA_SHADER_CACHE_MAX_SIZE="${builtins.toString (builtins.floor (glCacheSize / 1024 / 1024 / 1024))}G"
    ''}

    export LD_LIBRARY_PATH=${lib.makeLibraryPath [freetype vulkan-loader]}:$LD_LIBRARY_PATH
    PATH=${lib.makeBinPath [wine winetricks]}:"$PATH"
    USER="$(whoami)"
    RSI_LAUNCHER="$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/RSI Launcher/RSI Launcher.exe'

    # Ensure all tricks are installed
    ${lib.toShellVars {
      inherit tricks;
      tricksInstalled = 1;
    }}

    ${lib.getExe wineprefix-preparer}

    for trick in "${"\${tricks[@]}"}"; do
      if ! winetricks list-installed | grep -qw "$trick"; then
        echo 'winetricks: Installing '"$trick"
        winetricks -q -f "$trick"
        tricksInstalled=0
      fi
    done

    if [ "$tricksInstalled" -eq 0 ]; then
      # Ensure wineserver is restarted after tricks are installed.
      wineserver -k
    fi

    # If the launcher isn't installed, run the installer regardless of if the
    # prefix has already been created.
    if [ ! -e "$RSI_LAUNCHER" ]; then
      # Ensure the required directories for Star Citizen already exist, these
      # directories are were the game files will be installed to.
      mkdir -p "$WINEPREFIX"'/drive_c/Program Files/Roberts Space Industries/StarCitizen/'{LIVE,PTU}

      # Run the installer silently.
      WINEDLLOVERRIDES='dxwebsetup.exe,dotNetFx45_Full_setup.exe,winemenubuilder.exe=d' wine ${src} /S

      # Restart wineserver after the installer exits.
      wineserver -k
    fi

    # Enter the prefix's directory.
    cd "$WINEPREFIX"

    # Allow entering a shell, this is useful to execute wine commands, such as
    # `winecfg` or `wine reg add`.
    if [ "${"\${1:-}"}" = '--shell' ]; then
      echo 'Entered Shell for star-citizen'
      exec ${lib.getExe bashInteractive}
    fi

    # wine reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v NoTrayItemsDisplay /t REG_DWORD /d 1

    # Only execute `mangohud` if it exists on the system.
    if command -v mangohud > /dev/null 2>&1; then
      mangohud='mangohud'
    else
      mangohud=""
    fi

    ${preCommands}

    # Run the launcher.
    "$mangohud" wine ${wineFlags} "$RSI_LAUNCHER" --in-process-gpu "$@"

    wineserver -w

    ${postCommands}
  '';

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

    meta = {
      mainPrograma = "star-citizen";
      description = "Star Citizen installer and launcher";
      homepage = "https://robertsspaceindustries.com/";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [matthewpi];
      platforms = ["x86_64-linux"];
    };
  }
