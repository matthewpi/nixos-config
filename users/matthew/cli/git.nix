{pkgs, ...}: {
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
            else "op-ssh-sign";
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

    difftastic = {
      enable = true;
      background = "dark";
      color = "auto";
      display = "side-by-side";
    };

    aliases = {
      a = "add";
      aa = "add -A";

      c = "commit";
      cs = "commit -s";
      ca = "commit --amend";
      amend = "commit --amend --no-edit";

      s = "stash";
      sp = "stash push -S";
      sa = "stash apply";
    };
  };
}
