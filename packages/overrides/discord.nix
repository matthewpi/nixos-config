{
  discord-canary,
  gtk3,
  lib,
  python3,
  runCommand,
  stdenv,
  ...
}: {
  discord-canary = let
    pname = "discord-canary";
    binaryName =
      if stdenv.isLinux
      then "DiscordCanary"
      else desktopName;
    desktopName = "Discord Canary";
  in
    discord-canary.overrideAttrs (super: {
      installPhase = let
        disableBreakingUpdates =
          runCommand "disable-breaking-updates.py"
          {
            pythonInterpreter = "${python3.interpreter}";
            configDirName = lib.toLower binaryName;
          } ''
            mkdir -p $out/bin
            cp ${./disable-breaking-updates.py} $out/bin/disable-breaking-updates.py
            substituteAllInPlace $out/bin/disable-breaking-updates.py
            chmod +x $out/bin/disable-breaking-updates.py
          '';
        desktopItem = super.desktopItem;
        libPath = super.libPath;
      in ''
        runHook preInstall

        mkdir -p $out/{bin,opt/${binaryName},share/pixmaps,share/icons/hicolor/256x256/apps}
        mv * $out/opt/${binaryName}

        chmod +x $out/opt/${binaryName}/${binaryName}
        patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
            $out/opt/${binaryName}/${binaryName}

        wrapProgramShell $out/opt/${binaryName}/${binaryName} \
            "''${gappsWrapperArgs[@]}" \
            --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
            --prefix LD_LIBRARY_PATH : ${libPath}:$out/opt/${binaryName} \
            --run "${lib.getExe disableBreakingUpdates}"

        ln -s $out/opt/${binaryName}/${binaryName} $out/bin/
        # Without || true the install would fail on case-insensitive filesystems
        ln -s $out/opt/${binaryName}/${binaryName} $out/bin/${
          lib.strings.toLower binaryName
        } || true

        ln -s $out/opt/${binaryName}/discord.png $out/share/pixmaps/${pname}.png
        ln -s $out/opt/${binaryName}/discord.png $out/share/icons/hicolor/256x256/apps/${pname}.png

        ln -s "${desktopItem}/share/applications" $out/share/

        runHook postInstall
      '';
    });
}
