{
  fetchFromGitHub,
  hyprcursor,
  lib,
  rename,
  stdenvNoCC,
  unzip,
}: let
  dimensions = {
    palette = ["Frappe" "Latte" "Macchiato" "Mocha"];
    color = ["Blue" "Dark" "Flamingo" "Green" "Lavender" "Light" "Maroon" "Mauve" "Peach" "Pink" "Red" "Rosewater" "Sapphire" "Sky" "Teal" "Yellow"];
  };

  product = lib.attrsets.cartesianProductOfSets dimensions;
  variantName = {
    palette,
    color,
  }:
    (lib.strings.toLower palette) + color;
  variants = map variantName product;

  # Cursors that have animations
  animations = ["wait" "progress"];
in
  stdenvNoCC.mkDerivation rec {
    pname = "catppuccin-hyprcursors";
    version = "0.2.0";

    src = builtins.path {
      path = fetchFromGitHub {
        owner = "catppuccin";
        repo = "cursors";
        rev = "v${version}";
        hash = "sha256-xmW6FNy4d9SU/HsBgi9PT83tzxLeUd1YI4l9uNqOWH8=";
        sparseCheckout = ["cursors" "src"];
      };
      name = "catppuccin-hyprcursors";
    };

    nativeBuildInputs = [hyprcursor rename unzip];

    outputs = variants ++ ["out"];
    outputsToInstall = [];
    inherit animations;

    phases = ["unpackPhase" "installPhase"];
    installPhase = ''
      runHook preInstall

      # Get the pwd so we have a directory reference to fallback to.
      BASE="$(pwd)"

      # Used to generate hyprcursor metadata for a SVG cursor animation.
      function generate_animation_meta() {
        local ANIM="$2"
        local output=""
        for i in {1..12}; do
          output+="define_size = 64, $ANIM-$(printf "%02d" $i).svg,500\n"
        done

        echo -e "resize_algorithm = bilinear\n$output" >"$1"/"$ANIM"/meta.hl
      }

      for output in $(getAllOutputNames); do
        # Skip the output named "out".
        if [ "$output" == 'out' ]; then
          continue
        fi

        local outputDir="''${!output}"
        local iconsDir="$outputDir"/share/icons

        local variant=$(sed 's/\([A-Z]\)/-\1/g' <<< "$output")
        local variant=''${variant^}
        local themeName="Catppuccin-$variant-Cursors"

        # Switch to the directory with the svg cursors
        cd "$BASE"/src/"$themeName"

        # Create the output directory
        mkdir -p hyprcursors "$iconsDir"

        # Remove unnecessary SVGs
        rm -f *_24.svg
        rm -f index.theme

        # Move any animation SVGs into a directory with each individual animation frame
        for animation in $animations; do
          mkdir hyprcursors/"$animation"
          mv $animation-* hyprcursors/"$animation"/
        done

        # Move all the normal SVGs into their appropriate directories alongside a `meta.hl` file.
        for file in *.svg; do
          cursorName="''${file%.svg}"
          direct=hyprcursors/"$cursorName"
          mkdir "$direct"
          mv "$file" "$direct"
          echo -e "resize_algorithm = bilinear\ndefine_size = 64, $file" >"$direct"/meta.hl

          # For the `text` cursor, fix the hotspot (the actual "click point" of the cursor).
          if [ "$cursorName" == 'text' ]; then
            echo -e "hotspot_x = 0.5\nhotspot_y = 0.5" >>"$direct"/meta.hl
          fi
        done

        # Generate metadata for animations
        for animation in $animations; do
          generate_animation_meta hyprcursors "$animation"
        done

        # Generate manifest for the cursors
        echo -e "name = $themeName\ndescription = Soothing pastel mouse cursors\nversion = $version\ncursors_directory = hyprcursors" >manifest.hl

        # Compile the SVG cursors
        hyprcursor-util --create . --output "$iconsDir"

        # Strip hyprcursor-util `theme_` prefix from directory names
        cd "$iconsDir"
        rename 's/^theme_//' theme_*

        # Extract the xcursor theme to the same directory, this allows a user to use a single package and theme name
        # for both hyprcursor and an xcursor fallback.
        unzip "$BASE"/cursors/"$themeName".zip -d "$iconsDir"
      done

      # Needed to prevent breakage
      mkdir -p "$out"

      runHook postInstall
    '';

    meta = {
      description = "Soothing pastel mouse cursors";
      homepage = "https://github.com/catppuccin/cursors";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [matthewpi];
      platforms = lib.platforms.linux;
    };
  }
