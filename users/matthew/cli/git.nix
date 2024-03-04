{
  flavour,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;

    # User settings
    userEmail = "me@matthewp.io";
    userName = "Matthew Penner";

    # Enable Git LFS
    lfs.enable = true;

    # Ignore directories and files that should never be committed globally.
    ignores = [".direnv" "result*"];

    extraConfig = {
      # Disable advice.
      advice.detachedHead = false;

      # Change the default branch to master.
      init.defaultBranch = "master";

      # Use the 1Password SSH Agent.
      gpg = {
        format = "ssh";
        ssh = {
          program =
            if pkgs.stdenv.isDarwin
            then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            else "${pkgs._1password-gui}/share/1password/op-ssh-sign";
        };
      };
      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL873MsP1OFfffNC8n9WcVuOXOSW65/q26MIzib0K9k";
      commit.gpgSign = true;
      tag.gpgSign = true;

      # Use SSH for GitHub, even if a HTTP url is used.
      # TODO: disabled due to slowing Cargo git clones down dramatically.
      # url = {
      #   "git@github.com:" = {
      #     insteadOf = "https://github.com/";
      #   };
      # };

      # Enable the manyFiles feature.
      feature.manyFiles = false; # TODO: true (this option seems to piss of Cargo when dealing with submodules)

      # Enable the commit graph.
      core.commitgraph = false; # true (this option seems to piss of Cargo when dealing with submodules)

      # Write the commit graph persistently.
      feature.writeCommitGraph = false; # true (this option seems to piss of Cargo when dealing with submodules)
      fetch.writeCommitGraph = false; # true (this option seems to piss of Cargo when dealing with submodules)
    };

    # Use delta for diffing
    delta = {
      enable = true;
      options = {
        features = "catppuccin-${flavour}";
        line-numbers = true;
        navigate = true;
        side-by-side = true;
        true-color = "always"; # This setting defaults to "auto" which doesn't work for us.

        catppuccin-latte = {
          commit-decoration-style = "none";
          light = true;

          file-decoration-style = "none";
          file-style = "omit";

          hunk-header-decoration-style = "#bcc0cc ul"; # Surface 1
          hunk-header-file-style = "#6c6f85"; # Subtext 0
          hunk-header-line-number-style = "bold #40a02b"; # Green
          hunk-header-style = "file line-number syntax";

          line-numbers = true;
          line-numbers-left-format = " {nm:>3} │ "; # TODO: only make this have a space if side-by-side is enabled.
          line-numbers-left-style = "#bcc0cc"; # Surface 1
          line-numbers-right-format = " {np:>3} │ ";
          line-numbers-right-style = "#bcc0cc"; # Surface 1
          line-numbers-minus-style = "#d20f39"; # Red
          line-numbers-plus-style = "#40a02b"; # Green
          line-numbers-zero-style = "#8c8fa1"; # Overlay 1

          minus-emph-style = "normal #e64553"; # Maroon
          minus-style = "normal #f38ba8"; # Red (Mocha)

          plus-emph-style = "syntax #347326"; # Green hsl(109, 50%, 30%) TODO: work on this color more
          plus-style = "syntax #a6e3a1"; # Green (Mocha)

          syntax-theme = "Catppuccin-latte";
        };

        catppuccin-frappe = {
          commit-decoration-style = "none";
          dark = true;

          file-decoration-style = "none";
          file-style = "omit";

          hunk-header-decoration-style = "#51576d ul"; # Surface 1
          hunk-header-file-style = "#a5adce"; # Subtext 0
          hunk-header-line-number-style = "bold #a6d189"; # Green
          hunk-header-style = "file line-number syntax";

          line-numbers = true;
          line-numbers-left-format = " {nm:>3} │ "; # TODO: only make this have a space if side-by-side is enabled.
          line-numbers-left-style = "#51576d"; # Surface 1
          line-numbers-right-format = " {np:>3} │ ";
          line-numbers-right-style = "#51576d"; # Surface 1
          line-numbers-minus-style = "#e78284"; # Red
          line-numbers-plus-style = "#a6d189"; # Green
          line-numbers-zero-style = "#838ba7"; # Overlay 1

          minus-emph-style = "normal #d20f39"; # Red (Latte)
          minus-style = "normal #5e4855"; # Red (0.25 opacity on Base)

          plus-emph-style = "syntax #40a02b"; # Green (Latte)
          plus-style = "syntax #4d5b57"; # Green (0.25 opacity on Base)

          syntax-theme = "Catppuccin-frappe";
        };

        catppuccin-macchiato = {
          commit-decoration-style = "none";
          dark = true;

          file-decoration-style = "none";
          file-style = "omit";

          hunk-header-decoration-style = "#494d64 ul"; # Surface 1
          hunk-header-file-style = "#a5adcb"; # Subtext 0
          hunk-header-line-number-style = "bold #a6da95"; # Green
          hunk-header-style = "file line-number syntax";

          line-numbers = true;
          line-numbers-left-format = " {nm:>3} │ "; # TODO: only make this have a space if side-by-side is enabled.
          line-numbers-left-style = "#494d64"; # Surface 1
          line-numbers-right-format = " {np:>3} │ ";
          line-numbers-right-style = "#494d64"; # Surface 1
          line-numbers-minus-style = "#ed8796"; # Red
          line-numbers-plus-style = "#a6da95"; # Green
          line-numbers-zero-style = "#8087a2"; # Overlay 1

          minus-emph-style = "normal #d20f39"; # Red (Latte)
          minus-style = "normal #563f51"; # Red (0.25 opacity on Base)

          plus-emph-style = "syntax #40a02b"; # Green (Latte)
          plus-style = "syntax #455451"; # Green (0.25 opacity on Base)

          syntax-theme = "Catppuccin-macchiato";
        };

        catppuccin-mocha = {
          commit-decoration-style = "none";
          dark = true;

          file-decoration-style = "none";
          file-style = "omit";

          hunk-header-decoration-style = "#45475a ul"; # Surface 1
          hunk-header-file-style = "#a6adc8"; # Subtext 0
          hunk-header-line-number-style = "bold #a6e3a1"; # Green
          hunk-header-style = "file line-number syntax";

          line-numbers = true;
          line-numbers-left-format = " {nm:>3} │ "; # TODO: only make this have a space if side-by-side is enabled.
          line-numbers-left-style = "#45475a"; # Surface 1
          line-numbers-right-format = " {np:>3} │ ";
          line-numbers-right-style = "#45475a"; # Surface 1
          line-numbers-minus-style = "#f38ba8"; # Red
          line-numbers-plus-style = "#a6e3a1"; # Green
          line-numbers-zero-style = "#7f849c"; # Overlay 1

          minus-emph-style = "normal #d20f39"; # Red (Latte)
          minus-style = "normal #53394d"; # Red (0.25 opacity on Base)

          plus-emph-style = "syntax #40a02b"; # Green (Latte)
          plus-style = "syntax #404f4b"; # Green (0.25 opacity on Base)

          syntax-theme = "Catppuccin-mocha";
        };
      };
    };
  };
}
