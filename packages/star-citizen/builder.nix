{
  lib,
  runtimeShell,
  shellcheck-minimal,
  stdenv,
  writeTextFile,
}: {
  /**
  The name of the script to write.

  # Type

  ```
  String
  ```
  */
  name,
  /**
  The shell script's text, not including a shebang.
  TODO: better docs

  # Type

  ```
  String
  ```
  */
  preText ? null,
  /**
  The shell script's text, not including a shebang.

  # Type

  ```
  String
  ```
  */
  text,
  /**
  Inputs to add to the shell script's `$PATH` at runtime.

  # Type

  ```
  [String|Derivation]
  ```
  */
  runtimeInputs ? [],
  /**
  Extra environment variables to set at runtime.

  # Type

  ```
  AttrSet
  ```
  */
  runtimeEnv ? null,
  runtimeEnvLiteral ? null,
  /**
  `stdenv.mkDerivation`'s `meta` argument.

  # Type

  ```
  AttrSet
  ```
  */
  meta ? {},
  /**
  `stdenv.mkDerivation`'s `passthru` argument.

  # Type

  ```
  AttrSet
  ```
  */
  passthru ? {},
  /**
  The `checkPhase` to run. Defaults to `shellcheck` on supported
  platforms and `bash -n`.

  The script path will be given as `$target` in the `checkPhase`.

  # Type

  ```
  String
  ```
  */
  checkPhase ? null,
  /**
  Checks to exclude when running `shellcheck`, e.g. `[ "SC2016" ]`.

  See <https://www.shellcheck.net/wiki/> for a list of checks.

  # Type

  ```
  [String]
  ```
  */
  excludeShellChecks ? [],
  /**
  Extra command-line flags to pass to ShellCheck.

  # Type

  ```
  [String]
  ```
  */
  extraShellCheckFlags ? [],
  /**
  Bash options to activate with `set -o` at the start of the script.

  Defaults to `[ "errexit" "nounset" "pipefail" ]`.

  # Type

  ```
  [String]
  ```
  */
  bashOptions ? [
    "errexit"
    "nounset"
    "pipefail"
  ],
  /**
  Extra arguments to pass to `stdenv.mkDerivation`.

  :::note{.caution}
  Certain derivation attributes are used internally,
  overriding those could cause problems.
  :::

  # Type

  ```
  AttrSet
  ```
  */
  derivationArgs ? {},
  /**
  Whether to inherit the current `$PATH` in the script.

  # Type

  ```
  Bool
  ```
  */
  inheritPath ? true,
  /**
  Inputs to add to the shell script's `$LD_LIBRARY_PATH` at runtime.

  # Type

  ```
  [String|Derivation]
  ```
  */
  libraryPath ? [],
  /**
  Whether to inherit the current `$LD_LIBRARY_PATH` in the script.

  # Type

  ```
  Bool
  ```
  */
  inheritLibraryPath ? true,
}:
writeTextFile {
  inherit
    name
    meta
    passthru
    derivationArgs
    ;
  executable = true;
  destination = "/bin/${name}";
  allowSubstitutes = true;
  # preferLocalBuild = false;
  preferLocalBuild = true;
  text =
    ''
      #!${runtimeShell}

      ${lib.concatMapStringsSep "\n" (option: "set -o ${option}") bashOptions}
    ''
    + lib.optionalString (runtimeInputs != []) ''

      export PATH=${lib.makeBinPath runtimeInputs}${lib.optionalString inheritPath ":\"$PATH\""}
    ''
    + lib.optionalString (libraryPath != []) ''
      if [ -v LD_LIBRARY_PATH ]; then
        export LD_LIBRARY_PATH=${lib.makeLibraryPath libraryPath}${lib.optionalString inheritLibraryPath ":\"$LD_LIBRARY_PATH\""}
      else
        export LD_LIBRARY_PATH=${lib.makeLibraryPath libraryPath}
      fi
    ''
    + lib.optionalString (preText != null) ''

      ${preText}
    ''
    + lib.optionalString (runtimeEnv != null) ''
      # Runtime Environment
      ${lib.concatStrings (
        lib.mapAttrsToList (name: value: ''
          ${lib.toShellVar name value}
          export ${name}
        '')
        runtimeEnv
      )}
    ''
    + lib.optionalString (runtimeEnvLiteral != null) (
      lib.concatStrings (
        lib.mapAttrsToList (name: value: ''
          ${name}=${value}
          export ${name}
        '')
        runtimeEnvLiteral
      )
    )
    + ''

      ${text}
    '';

  checkPhase = let
    excludeFlags = lib.optionals (excludeShellChecks != []) [
      "--exclude"
      (lib.concatStringsSep "," excludeShellChecks)
    ];
    # GHC (=> shellcheck) isn't supported on some platforms (such as risc-v)
    # but we still want to use writeShellApplication on those platforms
    shellcheckCommand = lib.optionalString shellcheck-minimal.compiler.bootstrapAvailable ''
      # use shellcheck which does not include docs
      # pandoc takes long to build and documentation isn't needed for just running the cli
      ${lib.getExe shellcheck-minimal} ${
        lib.escapeShellArgs (excludeFlags ++ extraShellCheckFlags)
      } "$target"
    '';
  in
    if checkPhase == null
    then ''
      runHook preCheck
      ${stdenv.shellDryRun} "$target"
      ${shellcheckCommand}
      runHook postCheck
    ''
    else checkPhase;
}
