let
  validAccents = ["rosewater" "flamingo" "pink" "mauve" "red" "maroon" "peach" "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender"];
  validThemes = ["alacritty" "bat" "bottom" "btop" "hyprland" "k9s" "lazygit" "plymouth" "refind" "starship"];
  validVariants = ["latte" "frappe" "macchiato" "mocha"];
in
  {
    fetchFromGitHub,
    lib,
    stdenvNoCC,
    jq,
  }: let
    accents = validAccents;
    themes = validThemes;
    variants = validVariants;

    sources = {
      alacritty = fetchFromGitHub {
        owner = "catppuccin";
        repo = "alacritty";
        rev = "343cf8d65459ac8f6449cc98dd3648bcbd7e3766";
        hash = "sha256-5MUWHXs8vfl2/u6YXB4krT5aLutVssPBr+DiuOdMAto=";
      };

      bat = fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "d2bbee4f7e7d5bac63c054e4d8eca57954b31471";
        hash = "sha256-x1yqPCWuoBSx/cI94eA+AWwhiSA42cLNUOFJl7qjhmw=";
      };

      bottom = fetchFromGitHub {
        owner = "catppuccin";
        repo = "bottom";
        rev = "ed09bd5a5dd78d83acdc8ff5fdec40a6340ed1c2";
        hash = "sha256-Vi438I+YVvoD2xzq2t9hJ9R3a+2TlDdbakjFYFtjtXQ=";
      };

      btop = fetchFromGitHub {
        owner = "catppuccin";
        repo = "btop";
        rev = "1.0.0";
        hash = "sha256-J3UezOQMDdxpflGax0rGBF/XMiKqdqZXuX4KMVGTxFk=";
      };

      hyprland = fetchFromGitHub {
        owner = "catppuccin";
        repo = "hyprland";
        rev = "v1.3";
        hash = "sha256-jkk021LLjCLpWOaInzO4Klg6UOR4Sh5IcKdUxIn7Dis=";
      };

      k9s = fetchFromGitHub {
        owner = "catppuccin";
        repo = "k9s";
        rev = "fdbec82284744a1fc2eb3e2d24cb92ef87ffb8b4";
        hash = "sha256-9h+jyEO4w0OnzeEKQXJbg9dvvWGZYQAO4MbgDn6QRzM=";
      };

      lazygit = fetchFromGitHub {
        owner = "catppuccin";
        repo = "lazygit";
        rev = "v2.2.0";
        hash = "sha256-mHB4Db71uKblCDab47eBIKd63ekYjvXOqUkY/ELMDQQ=";
      };

      plymouth = fetchFromGitHub {
        owner = "catppuccin";
        repo = "plymouth";
        rev = "e0f58d6fcf3dbc2d35dfc4fec394217fbfa92666";
        hash = "sha256-He6ER1QNrJCUthFoBBGHBINouW/tozxQy3R79F5tsuo=";
      };

      refind = fetchFromGitHub {
        owner = "catppuccin";
        repo = "refind";
        rev = "ff0b593c19bb9b469ee0ee36068b8d373f0fadc5";
        hash = "sha256-itUMo0lA23bJzH0Ndq7L2IaEYoVdNPYxbB/VWkRfRso=";
      };

      starship = fetchFromGitHub {
        owner = "catppuccin";
        repo = "starship";
        rev = "3c4749512e7d552adf48e75e5182a271392ab176";
        hash = "sha256-t/Hmd2dzBn0AbLUlbL8CBt19/we8spY5nMP0Z+VPMXA=";
      };
    };

    selectedSources = map (themeName: builtins.getAttr themeName sources) themes;
  in
    lib.checkListOfEnum "catppuccin: accent" validAccents accents
    lib.checkListOfEnum "catppuccin: themes"
    validThemes
    themes
    lib.checkListOfEnum "catppuccin: variant"
    validVariants
    variants
    stdenvNoCC.mkDerivation {
      pname = "catppuccin";
      version = "unstable-2024-10-22";

      srcs = selectedSources;

      unpackPhase = ''
        for s in $selectedSources; do
          b=$(basename "$s")
          cp "$s" ''${b#*-}
        done
      '';

      inherit accents variants;

      buildInputs = [jq];

      installPhase =
        ''
          runHook preInstall

        ''
        + lib.optionalString (lib.elem "alacritty" themes) ''
          mkdir -p "$out"/alacritty
          for variant in $variants; do
            cp ${sources.alacritty}/catppuccin-"$variant".toml "$out"/alacritty/Catppuccin-"$variant".toml
          done

        ''
        + lib.optionalString (lib.elem "bat" themes) ''
          mkdir -p "$out"/bat
          for variant in $variants; do
            local capitalizedVariant=$(sed 's/^\(.\)/\U\1/' <<< "$variant")
            cp '${sources.bat}/themes/Catppuccin '"$capitalizedVariant".tmTheme "$out"/bat/
          done

        ''
        + lib.optionalString (lib.elem "btop" themes) ''
          mkdir -p "$out"/btop
          for variant in $variants; do
            cp ${sources.btop}/themes/catppuccin_"$variant".theme "$out"/btop/
          done

        ''
        + lib.optionalString (lib.elem "bottom" themes) ''
          mkdir -p "$out"/bottom
          for variant in $variants; do
            cp ${sources.bottom}/themes/"$variant".toml "$out"/bottom/
          done

        ''
        + lib.optionalString (lib.elem "hyprland" themes) ''
          mkdir -p "$out"/hyprland
          for variant in $variants; do
            cp ${sources.hyprland}/themes/"$variant".conf "$out"/hyprland/
          done

        ''
        + lib.optionalString (lib.elem "k9s" themes) ''
          mkdir -p "$out"/k9s
          for variant in $variants; do
            cp ${sources.k9s}/dist/catppuccin-"$variant".yaml "$out"/k9s/
            cp ${sources.k9s}/dist/catppuccin-"$variant"-transparent.yaml "$out"/k9s/
          done

        ''
        + lib.optionalString (lib.elem "lazygit" themes) ''
          mkdir -p "$out"/lazygit/{themes,themes-mergable}
          for variant in $variants; do
            for accent in $accents; do
              cp ${sources.lazygit}/themes/"$variant"/"$accent".yml "$out"/lazygit/themes/"$variant"-"$accent".yaml
              cp ${sources.lazygit}/themes-mergable/"$variant"/"$accent".yml "$out"/lazygit/themes-mergable/"$variant"-"$accent".yaml
            done
          done

        ''
        + lib.optionalString (lib.elem "plymouth" themes) ''
          for variant in $variants; do
            mkdir -p "$out"/share/plymouth/themes/catppuccin-"$variant"
            cp ${sources.plymouth}/themes/catppuccin-$variant/* "$out"/share/plymouth/themes/catppuccin-"$variant"
            sed -i 's:\(^ImageDir=\)/usr:\1'"$out"':' "$out"/share/plymouth/themes/catppuccin-"$variant"/catppuccin-"$variant".plymouth
          done

        ''
        + lib.optionalString (lib.elem "refind" themes) ''
          mkdir -p "$out"/refind/assets
          for variant in $variants; do
            cp ${sources.refind}/"$variant".conf "$out"/refind/
            cp -r ${sources.refind}/assets/"$variant" "$out"/refind/assets/
          done

        ''
        + lib.optionalString (lib.elem "starship" themes) ''
          mkdir -p "$out"/starship
          for variant in $variants; do
            cp ${sources.starship}/themes/"$variant".toml "$out"/starship
          done

        ''
        + ''
          runHook postInstall
        '';

      meta = {
        description = "Soothing pastel themes";
        homepage = "https://github.com/catppuccin/catppuccin";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [matthewpi];
        platforms = lib.platforms.all;
      };
    }
