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
        normal.family = "Monaspace Neon NF";
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
    enable = false;
    settings = {
      font-family = "Monaspace Neon NF";
      font-size = 10;
      font-feature = [
        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv01-cv09-figure-variants
        "cv01 = 2" # 0 (slash)
        # "cv02 = 0" # 1

        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv10-cv29-letter-variants
        "cv10 = 1" # Alternatives for "l i" (Neon, Argon, Xenon, Radon)
        "cv11 = 1" # Alternatives for "j f r t" (Neon, Argon)

        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv30-cv59-symbol-variants
        # "cv30 = 0" # * (vertically aligned)
        "cv31 = 1" # * (6-points instead of 5)
        # "cv32 = 0" # >= <= (angled lower-line)

        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv60-cv79-optional-ligatures
        # "cv60 = 0" # <= =>
        # "cv61 = 0" # []
        # "cv62 = 0" # @_

        "calt" # Texture Healing
        "liga" # ... /// // !! || ;; ;;;
        "ss01" # === !== =!= =/= /== /= #= == != ~~ =~ !~ ~- -~ &=
        "ss02" # >= <=
        "ss03" # <--> <-> <!-- <-- --> <- -> <~> <~~ ~~> <~ ~>
        "ss04" # </ /> </> <>
        "ss05" # [| |] /\ \/ |> <| <|> {| |}
        "ss06" # ### +++ &&&
        "ss07" # -:- =:= :>: :<: ::> <:: :: :::
        "ss08" # ..= ..- ..< .= .-
        "ss09" # <=> <<= =>> =<< => << >>
        "ss10" # #[ #(
      ];
      cursor-style = "block";
      cursor-click-to-move = true;
      background-opacity = 0.75;
    };
  };
}
