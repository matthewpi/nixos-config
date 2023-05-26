# TODO: remove once https://github.com/NixOS/nixpkgs/pull/234267 is merged
{
  jetbrains,
  lib,
  python3,
  stdenv,
  coreutils,
  gnugrep,
  which,
  git,
  libsecret,
  e2fsprogs,
  libnotify,
  ...
}: {
  # All of this just to add `python3` to the lib.makeBinPath call.
  # What a waste of time.
  goland = jetbrains.goland.overrideAttrs (attrs: {
    installPhase = let
      jdk = jetbrains.jdk;
      desktopItem = attrs.desktopItem;
      pname = attrs.pname;
      vmoptsFile = attrs.vmoptsFile;
      loName = lib.toLower "Goland";
      hiName = lib.toUpper "Goland";
      extraLdPath = [];
      extraWrapperArgs = [];
    in ''
      runHook preInstall

      mkdir -p $out/{bin,$pname,share/pixmaps,libexec/${pname}}
      cp -a . $out/$pname
      [[ -f $out/$pname/bin/${loName}.png ]] && ln -s $out/$pname/bin/${loName}.png $out/share/pixmaps/${pname}.png
      [[ -f $out/$pname/bin/${loName}.svg ]] && ln -s $out/$pname/bin/${loName}.svg $out/share/pixmaps/${pname}.svg
      mv bin/fsnotifier* $out/libexec/${pname}/.

      jdk=${jdk.home}
      item=${desktopItem}

      makeWrapper "$out/$pname/bin/${loName}.sh" "$out/bin/${pname}" \
        --prefix PATH : "$out/libexec/${pname}:${lib.makeBinPath [jdk coreutils gnugrep which git python3]}" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath ([
          # Some internals want libstdc++.so.6
          stdenv.cc.cc.lib
          libsecret
          e2fsprogs
          libnotify
        ]
        ++ extraLdPath)}" \
        ${lib.concatStringsSep " " extraWrapperArgs} \
        --set-default JDK_HOME "$jdk" \
        --set-default ANDROID_JAVA_HOME "$jdk" \
        --set-default JAVA_HOME "$jdk" \
        --set-default JETBRAINSCLIENT_JDK "$jdk" \
        --set ${hiName}_JDK "$jdk" \
        --set ${hiName}_VM_OPTIONS ${vmoptsFile}

      ln -s "$item/share/applications" $out/share

      runHook postInstall
    '';
  });
}
