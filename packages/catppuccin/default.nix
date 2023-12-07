let
  validAccents = ["rosewater" "flamingo" "pink" "mauve" "red" "maroon" "peach" "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender"];
  validThemes = ["bat" "blackbox" "bottom" "btop" "hyprland" "k9s" "lazygit" "plymouth" "refind" "rofi" "starship" "waybar"];
  validVariants = ["latte" "frappe" "macchiato" "mocha"];
in
  {
    fetchFromGitHub,
    lib,
    stdenvNoCC,
    jq,
    # accents ? validAccents,
    # themes ? validThemes,
    # variants ? validVariants,
  }: let
    accents = validAccents;
    themes = validThemes;
    variants = validVariants;

    sources = {
      bat = fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
        hash = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
      };

      blackbox = fetchFromGitHub {
        owner = "catppuccin";
        repo = "blackbox";
        rev = "ba04186c5b722926b538a71b2186be5bf32894d1";
        hash = "sha256-JkbJbdCP0ple0t7k/DlXtVKwluATCnf2kbRcryGlViM=";
      };

      bottom = fetchFromGitHub {
        owner = "catppuccin";
        repo = "bottom";
        rev = "c0efe9025f62f618a407999d89b04a231ba99c92";
        hash = "sha256-VaHX2I/Gn82wJWzybpWNqU3dPi3206xItOlt0iF6VVQ=";
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
        rev = "v1.2";
        hash = "sha256-07B5QmQmsUKYf38oWU3+2C6KO4JvinuTwmW1Pfk8CT8=";
      };

      k9s = fetchFromGitHub {
        owner = "catppuccin";
        repo = "k9s";
        rev = "516f44dd1a6680357cb30d96f7e656b653aa5059";
        hash = "sha256-PtBJRBNbLkj7D2ko7ebpEjbfK9Ywjs7zbE+Y8FQVEfA=";
      };

      lazygit = fetchFromGitHub {
        owner = "catppuccin";
        repo = "lazygit";
        rev = "0543c28e8af1a935f8c512ad9451facbcc17d8a8";
        hash = "sha256-OVihY5E+elPKag2H4RyWiSv+MdIqHtfGNM3/1u2ik6U=";
      };

      plymouth = fetchFromGitHub {
        owner = "catppuccin";
        repo = "plymouth";
        rev = "d4105cf336599653783c34c4a2d6ca8c93f9281c";
        hash = "sha256-quBSH8hx3gD7y1JNWAKQdTk3CmO4t1kVo4cOGbeWlNE=";
      };

      refind = fetchFromGitHub {
        owner = "catppuccin";
        repo = "refind";
        rev = "ff0b593c19bb9b469ee0ee36068b8d373f0fadc5";
        hash = "sha256-itUMo0lA23bJzH0Ndq7L2IaEYoVdNPYxbB/VWkRfRso=";
      };

      rofi = fetchFromGitHub {
        owner = "catppuccin";
        repo = "rofi";
        rev = "5350da41a11814f950c3354f090b90d4674a95ce";
        hash = "sha256-DNorfyl3C4RBclF2KDgwvQQwixpTwSRu7fIvihPN8JY=";
      };

      starship = fetchFromGitHub {
        owner = "catppuccin";
        repo = "starship";
        rev = "3e3e54410c3189053f4da7a7043261361a1ed1bc";
        hash = "sha256-soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
      };

      waybar = fetchFromGitHub {
        owner = "catppuccin";
        repo = "waybar";
        rev = "v1.0";
        hash = "sha256-vfwfBE3iqIN1cGoItSssR7h0z6tuJAhNarkziGFlNBw=";
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
      version = "unstable-2023-10-09";

      srcs = selectedSources;

      unpackPhase = ''
        for s in $selectedSources; do
          b=$(basename $s)
          cp $s ''${b#*-}
        done
      '';

      inherit accents variants;

      buildInputs = [jq];

      installPhase =
        ''
          runHook preInstall

        ''
        + lib.optionalString (lib.elem "bat" themes) ''
          mkdir -p $out/bat
          for variant in $variants; do
            cp "${sources.bat}/Catppuccin-$variant.tmTheme" "$out/bat/"
          done

        ''
        + lib.optionalString (lib.elem "blackbox" themes) ''
          mkdir -p $out/blackbox
          for variant in $variants; do
            local capitalizedVariant=$(sed 's/^\(.\)/\U\1/' <<< "$variant")
            cat "${sources.blackbox}/src/Catppuccin-$capitalizedVariant.json" | jq --arg name "Catppuccin-$variant" '.name = $name' > "$out/blackbox/Catppuccin-$variant.json"
          done

        ''
        + lib.optionalString (lib.elem "btop" themes) ''
          mkdir -p $out/btop
          for variant in $variants; do
            cp "${sources.btop}/themes/catppuccin_$variant.theme" "$out/btop/"
          done

        ''
        + lib.optionalString (lib.elem "bottom" themes) ''
          mkdir -p $out/bottom
          for variant in $variants; do
            cp "${sources.bottom}/themes/$variant.toml" "$out/bottom/"
          done

        ''
        + lib.optionalString (lib.elem "hyprland" themes) ''
          mkdir -p $out/hyprland
          for variant in $variants; do
            cp "${sources.hyprland}/themes/$variant.conf" "$out/hyprland/"
          done

        ''
        + lib.optionalString (lib.elem "k9s" themes) ''
          mkdir -p $out/k9s
          for variant in $variants; do
            cp "${sources.k9s}/dist/$variant.yml" "$out/k9s/"
          done

        ''
        + lib.optionalString (lib.elem "lazygit" themes) ''
          mkdir -p $out/lazygit/{themes,themes-mergable}
          for variant in $variants; do
            for accent in $accents; do
              cp "${sources.lazygit}/themes/$variant/$variant-$accent.yml" "$out/lazygit/themes/"
              cp "${sources.lazygit}/themes-mergable/$variant/$variant-$accent.yml" "$out/lazygit/themes-mergable/"
            done
          done

        ''
        + lib.optionalString (lib.elem "plymouth" themes) ''
          for variant in $variants; do
            mkdir -p $out/share/plymouth/themes/catppuccin-$variant
            cp ${sources.plymouth}/themes/catppuccin-$variant/* $out/share/plymouth/themes/catppuccin-$variant
            sed -i 's:\(^ImageDir=\)/usr:\1'"$out"':' $out/share/plymouth/themes/catppuccin-$variant/catppuccin-$variant.plymouth
          done

        ''
        + lib.optionalString (lib.elem "rofi" themes) ''
          mkdir -p $out/rofi
          for variant in $variants; do
            cp ${sources.rofi}/basic/.local/share/rofi/themes/catppuccin-$variant.rasi $out/rofi/
          done

        ''
        + lib.optionalString (lib.elem "refind" themes) ''
          mkdir -p $out/refind/assets
          for variant in $variants; do
            cp ${sources.refind}/$variant.conf $out/refind/
            cp -r ${sources.refind}/assets/$variant $out/refind/assets/
          done

        ''
        + lib.optionalString (lib.elem "starship" themes) ''
          mkdir -p $out/starship
          for variant in $variants; do
            cp "${sources.starship}/palettes/$variant.toml" "$out/starship"
          done

        ''
        + lib.optionalString (lib.elem "waybar" themes) ''
          mkdir -p $out/waybar
          for variant in $variants; do
            cp ${sources.waybar}/$variant.css $out/waybar/
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
