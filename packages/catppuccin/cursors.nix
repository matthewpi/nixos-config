{
  fetchFromGitHub,
  hyprcursor,
  inkscape,
  just,
  lib,
  stdenvNoCC,
  xcursorgen,
  xcur2png,
}: let
  dimensions = {
    palette = ["Frappe" "Latte" "Macchiato" "Mocha"];
    color = ["Blue" "Dark" "Flamingo" "Green" "Lavender" "Light" "Maroon" "Mauve" "Peach" "Pink" "Red" "Rosewater" "Sapphire" "Sky" "Teal" "Yellow"];
  };

  variantName = {
    palette,
    color,
  }:
    (lib.strings.toLower palette) + color;

  variants = lib.mapCartesianProduct variantName dimensions;
in
  stdenvNoCC.mkDerivation rec {
    pname = "catppuccin-cursors";
    version = "0.4.0";

    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "cursors";
      rev = "v${version}";
      hash = "sha256-VxLwZkZdV1xH4jeqtszqSnhNrgF3uamEXBLPKIc4lXE=";
    };

    nativeBuildInputs = [hyprcursor inkscape just xcursorgen xcur2png];

    outputs = variants ++ ["out"]; # dummy "out" output to prevent breakage

    outputsToInstall = [];

    buildPhase = ''
      runHook preBuild

      patchShebangs .

      just all_with_hyprcursor

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      for output in $(getAllOutputNames); do
        if [ "$output" != "out" ]; then
          local outputDir="''${!output}"
          local iconsDir="$outputDir"/share/icons

          mkdir -p "$iconsDir"

          # Convert to kebab case with the first letter of each word capitalized
          local variant=$(sed 's/\([A-Z]\)/-\1/g' <<< "$output")
          local variant=''${variant,,}

          mv "dist/catppuccin-$variant-cursors" "$iconsDir"
        fi
      done

      # Needed to prevent breakage
      mkdir -p "$out"

      runHook postInstall
    '';

    meta = {
      description = "Soothing pastel mouse cursors";
      homepage = "https://github.com/catppuccin/cursors";
      license = lib.licenses.gpl2;
      maintainers = with lib.maintainers; [matthewpi];
      platforms = lib.platforms.linux;
    };
  }
