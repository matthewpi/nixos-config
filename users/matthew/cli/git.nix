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

    # Use the 1Password SSH Agent for commit signing.
    signing = {
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL873MsP1OFfffNC8n9WcVuOXOSW65/q26MIzib0K9k";
      signByDefault = true;
      signer =
        if pkgs.stdenv.isDarwin
        then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "op-ssh-sign";
    };

    extraConfig = {
      # Disable advice.
      advice.detachedHead = false;

      # Change the default branch to master.
      init.defaultBranch = "master";

      # # Use SSH for GitHub, even if a HTTP url is used.
      # url."git@github.com:".insteadOf = "https://github.com/";

      # Enable the manyFiles feature.
      feature.manyFiles = true; # NOTE: this option seems to piss of Cargo when dealing with submodules

      # Enable the commit graph.
      core.commitgraph = true; # NOTE: this option seems to piss of Cargo when dealing with submodules

      # Write the commit graph persistently.
      feature.writeCommitGraph = true; # NOTE: this option seems to piss of Cargo when dealing with submodules
      fetch.writeCommitGraph = true; # NOTE: this option seems to piss of Cargo when dealing with submodules
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
      ca = "commit --amend";
      amend = "commit --amend --no-edit";

      d = "diff";
      dc = "diff --cached";

      k = "kubectl";

      r = "rebase";

      s = "stash";
      sa = "stash apply";
      sl = "stash list";
      sp = "stash push -S";
      ss = "stash show";
    };
  };
}
