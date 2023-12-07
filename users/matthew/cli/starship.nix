{
  flavour,
  lib,
  pkgs,
  ...
}: let
  # This clusterfuck is used to avoid a little problem in Nix called IFD (Import From Deriviation).
  #
  # Previously, this config was just able to use IFD to import an additional TOML file and append it
  # to our custom settings, however since we are now building this system using Hydra, IFD is not
  # allowed, hence we need to do some black magic to make it work.
  runPythonScriptWith = {
    # name of the resulting derivation
    name,
    python ? pkgs.python3,
  }: pythonScript:
    pkgs.runCommand name {
      nativeBuildInputs = [
        python
      ];
      passAsFile = [
        "pythonScript"
      ];
      inherit pythonScript;
    } ''
      exec python3 "$pythonScriptPath"
    '';
in {
  programs.starship = {
    enable = true;
  };

  xdg.configFile."starship.toml".source = let
    settings = {
      palette = "catppuccin_${flavour}";

      format = lib.concatStrings [
        "$all"
        "$hostname"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$sudo"
        "$shell"
        "$character"
      ];

      aws = {
        disabled = true;
        symbol = " ";
      };

      azure = {
        disabled = true;
      };

      battery = {
        disabled = true;
      };

      buf = {
        disabled = true;
        symbol = " ";
      };

      bun = {
        disabled = true;
      };

      c = {
        disabled = true;
        symbol = " ";
      };

      cmake = {
        disabled = true;
      };

      cobol = {
        disabled = true;
      };

      cmd_duration = {
        disabled = false;
      };

      conda = {
        disabled = true;
        symbol = " ";
      };

      container = {
        disabled = true;
        format = "via [$symbol $name]($style) ";
        style = "bright-blue bold dimmed";
      };

      crystal = {
        disabled = true;
      };

      daml = {
        disabled = true;
      };

      dart = {
        disabled = true;
        symbol = " ";
      };

      deno = {
        disabled = true;
      };

      directory = {
        disabled = false;
        read_only = " ";
      };

      docker_context = {
        disabled = true;
        symbol = " ";
      };

      dotnet = {
        disabled = true;
        symbol = " ";
      };

      elixir = {
        disabled = true;
        symbol = " ";
      };

      elm = {
        disabled = true;
        symbol = " ";
      };

      env_var = {
        disabled = true;
      };

      erlang = {
        disabled = true;
        symbol = " ";
      };

      fill = {
        disabled = true;
      };

      gcloud = {
        disabled = true;
        symbol = " ";
      };

      git_branch = {
        symbol = " ";
      };

      git_commit = {
        disabled = false;
      };

      git_metrics = {
        disabled = true;
      };

      git_state = {
        disabled = false;
      };

      git_status = {
        disabled = false;
      };

      golang = {
        disabled = false;
        symbol = " ";
      };

      guix_shell = {
        disabled = true;
      };

      haskell = {
        disabled = true;
        symbol = " ";
      };

      haxe = {
        disabled = true;
        symbol = "⌘ ";
      };

      helm = {
        disabled = true;
      };

      hostname = {
        disabled = false;
        format = "at [$ssh_symbol$hostname]($style) ";
        style = "bold green";
        ssh_only = true;
        ssh_symbol = " ";
      };

      java = {
        disabled = true;
        symbol = " ";
      };

      jobs = {
        disabled = false;
      };

      julia = {
        disabled = true;
        symbol = " ";
      };

      kotlin = {
        disabled = true;
      };

      kubernetes = {
        disabled = true;
        symbol = "󱃾 ";
      };

      line_break = {
        disabled = false;
      };

      localip = {
        disabled = true;
      };

      lua = {
        disabled = true;
        symbol = " ";
      };

      memory_usage = {
        disabled = true;
        symbol = " ";
      };

      meson = {
        disabled = true;
        symbol = "喝 ";
      };

      hg_branch = {
        disabled = true;
        symbol = " ";
      };

      nim = {
        disabled = true;
        symbol = " ";
      };

      nix_shell = {
        disabled = false;
        # symbol = " ";
        symbol = " ";
      };

      nodejs = {
        disabled = false;
        symbol = " ";
        # symbol = " ";
      };

      ocaml = {
        disabled = true;
      };

      opa = {
        disabled = true;
      };

      openstack = {
        disabled = true;
      };

      os = {
        disabled = true;
        symbols = {
          Alpine = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "﯑ ";
          Gentoo = " ";
          HardenedBSD = "ﲊ ";
          Illumos = " ";
          Linux = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = " ";
          openSUSE = " ";
          OracleLinux = " ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          Redox = " ";
          Solus = "ﴱ ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Windows = " ";
        };
      };

      package = {
        disabled = true;
        symbol = " ";
      };

      perl = {
        disabled = true;
        symbol = " ";
      };

      php = {
        disabled = true;
        symbol = " ";
      };

      pulumi = {
        disabled = true;
      };

      purescript = {
        disabled = true;
      };

      python = {
        disabled = true;
        symbol = " ";
      };

      rlang = {
        disabled = true;
        symbol = "ﳒ ";
      };

      raku = {
        disabled = true;
      };

      red = {
        disabled = true;
      };

      ruby = {
        disabled = true;
        symbol = " ";
      };

      rust = {
        disabled = true;
        symbol = " ";
      };

      scala = {
        disabled = true;
        symbol = " ";
      };

      shell = {
        disabled = true;
      };

      shlvl = {
        disabled = true;
        symbol = " ";
      };

      singularity = {
        disabled = true;
      };

      spack = {
        disabled = true;
        symbol = "🅢 ";
      };

      status = {
        disabled = true;
      };

      sudo = {
        disabled = true;
        format = "[$symbol]($style) ";
        style = "bold blue";
        symbol = "🧙";
        allow_windows = false;
      };

      swift = {
        disabled = true;
        symbol = "ﯣ ";
      };

      terraform = {
        disabled = true;
      };

      time = {
        disabled = true;
      };

      username = {
        disabled = true;
      };

      vagrant = {
        disabled = true;
        symbol = " ";
      };

      vlang = {
        disabled = true;
      };

      vcsh = {
        disabled = true;
      };

      zig = {
        disabled = true;
      };
    };

    settingsFormat = pkgs.formats.toml {};
    settingsFile = settingsFormat.generate "starship.toml" settings;
  in
    runPythonScriptWith {
      name = "starship.toml";
      python = pkgs.python3.withPackages (pp: [
        pp.jsonmerge
        pp.toml
      ]);
    } ''
      from jsonmerge import merge
      import os
      import toml
      with open("${settingsFile}") as settings_file:
        settings = toml.load(settings_file)
      with open("${pkgs.catppuccin}/starship/${flavour}.toml") as palette_file:
        palette = toml.load(palette_file)
      merged = merge(settings, palette)
      with open(os.environ["out"], "w") as out:
        toml.dump(merged, out)
    '';
}
