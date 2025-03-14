{
  programs.alacritty = {
    enable = true;

    settings = {
      env = {
        TERM_PROGRAM = "alacritty";
        TERM = "xterm-256color";
      };

      window = {
        decorations = "None";
        opacity = 0.75;
        blur = true;
        padding = {
          x = 4;
          y = 1;
        };
      };

      font = {
        size = 10.0;
        normal.family = "MonaspiceNe Nerd Font"; # "Monaspace Neon";
      };

      cursor.style.shape = "Beam";

      general.ipc_socket = false;

      keyboard.bindings = [
        {
          mods = "Control";
          key = "V";
          action = "Paste";
        }
      ];
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Monaspace Neon"; # "MonaspiceNe Nerd Font Mono"
      font-size = 10;
      font-feature = [
        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv01-cv09-figure-variants
        "cv01 = 2" # 0 (slash)
        # "cv02 = 1" # 1
        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv10-cv29-letter-variants
        # "cv10 = 0" # l i (Neon, Argon, Xenon, Radon)
        # "cv11 = 0" # j f r t (Neon, Argon)
        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv30-cv59-symbol-variants
        # "cv30 = 0" # * (vertically aligned)
        # "cv31 = 0" # * (6-points)
        # "cv32 = 0" # >= <= (angled lower-line)
        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv60-cv79-optional-ligatures
        # "cv60 = 0" # <= =>
        # "cv61 = 0" # []
        # "cv62 = 0" # @_
        "calt" # Texture Healing
        "ss01" # === !== =!= =/= /== /= #= == != ~~ =~ !~ ~- -~ &=
        "ss02" # >= <=
        # "ss03" # <--> <-> <!-- <-- --> <- -> <~> <~~ ~~> <~ ~>
        # "ss04" # </ /> </> <>
        "ss05" # [| |] /\ \/ |> <| <|> {| |}
        "ss06" # ### +++ &&&
        "ss07" # -:- =:= :>: :<: ::> <:: :: :::
        "ss08" # ..= ..- ..< .= .-
        "ss09" # <=> <<= =>> =<< => << >>
        "ss10" # #[ #(
        "liga" # ... /// // !! || ;; ;;;
      ];
      cursor-style = "block";
      cursor-click-to-move = true;
      background-opacity = 0.75;
    };
  };
}
