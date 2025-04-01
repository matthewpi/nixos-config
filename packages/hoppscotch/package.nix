{
  darwin,
  fetchFromGitHub,
  gcc,
  lib,
  nodejs,
  node-gyp,
  node-pre-gyp,
  openssl,
  pkg-config,
  python3,
  pnpm_10,
  prisma,
  prisma-engines,
  stdenv,
  cairo,
  pango,
  pixman,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hoppscotch";
  version = "2025.3.0";

  src = fetchFromGitHub {
    owner = "hoppscotch";
    repo = "hoppscotch";
    tag = finalAttrs.version;
    hash = "sha256-XIItQYkUD6NGyM7ggiQ2K5tIY7XIHF5ctzp3b7l31L4=";
  };

  doCheck = false;

  pnpmDeps = pnpm_10.fetchDeps {
    inherit (finalAttrs) pname src;
    hash = "sha256-euV/K+Hrsp4v5JabcdAqqRqbttAWm1xprc3erMFczCg=";
  };

  nativeBuildInputs = [
    gcc
    nodejs
    nodejs.pkgs.node-gyp-build
    node-gyp
    node-pre-gyp
    pkg-config
    python3
    pnpm_10.configHook
    prisma
  ];
  buildInputs =
    [
      openssl

      # needed for node-canvas
      cairo
      pango
      pixman
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin (
      with darwin.apple_sdk.frameworks; [CoreText]
    );

  env = {
    # PRISMA_BINARY_PATH = lib.getExe' prisma "prisma";
    PRISMA_SCHEMA_ENGINE_BINARY = lib.getExe' prisma-engines "schema-engine";
    PRISMA_QUERY_ENGINE_BINARY = lib.getExe' prisma-engines "query-engine";
    PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines}/lib/libquery_engine.node";

    CPPFLAGS = "-I${nodejs}/include/node";
  };

  preBuild = ''
    # Link Node.js headers so `isolated-vm` can build within the Nix sandbox.
    mkdir -p "$HOME"/.node-gyp/${nodejs.version}
    echo 9 > "$HOME"/.node-gyp/${nodejs.version}/installVersion
    ln -sfv ${nodejs}/include "$HOME"/.node-gyp/${nodejs.version}
    export npm_config_nodedir=${nodejs}

    pushd node_modules/.pnpm/argon2@0.41.1/node_modules/argon2
    if [ -z "$npm_config_node_gyp" ]; then
      export npm_config_node_gyp=${node-gyp}/lib/node_modules/node-gyp/bin/node-gyp.js
    fi
    "$npm_config_node_gyp" rebuild
    popd

    pushd node_modules/.pnpm/bcrypt@5.1.1/node_modules/bcrypt
    node-pre-gyp install --prefer-offline --build-from-source --nodedir=${nodejs}/include/node
    popd

    pnpm rebuild --recursive --pending --use-stderr --stream
  '';

  buildPhase = ''
    runHook preBuild

    cp .env.example .env
    cp .env.example .env.development

    echo 'Generating prisma for hoppscotch-backend...'
    (cd packages/hoppscotch-backend; prisma generate)
    echo 'Prisma generated for hoppscotch-backend!'

    echo 'Running graphql-codegen for hoppscotch-selfhost-desktop...'
    (cd packages/hoppscotch-selfhost-desktop; pnpm graphql-codegen --config gql-codegen.yml)
    echo 'graphql-codegen completed for hoppscotch-selfhost-desktop'

    # Equivalent of `pnpm run generate` for this project. We do this so extra
    # args can be added to `pnpm` to get the output to print properly in the
    # event of a failure.
    pnpm run --recursive --use-stderr --stream do-build-prod

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp --recursive "$(pwd)" "$out"

    runHook postInstall
  '';

  # TODO: is this necessary anymore?
  postFixup = ''
    rm -f "$out"/packages/hoppscotch-backend/node_modules/jwt
    rm -f "$out"/packages/hoppscotch-selfhost-desktop/node_modules/environments.api
    rm -f "$out"/packages/hoppscotch-selfhost-desktop/node_modules/event
    rm -f "$out"/packages/hoppscotch-selfhost-desktop/node_modules/shell
    rm -f "$out"/packages/hoppscotch-selfhost-desktop/node_modules/tauri
  '';

  meta = {
    description = "Open source API development ecosystem";
    longDescription = ''
      Hoppscotch is a lightweight, web-based API development suite. It was built
      from the ground up with ease of use and accessibility in mind providing
      all the functionality needed for API developers with minimalist,
      unobtrusive UI.
    '';
    homepage = "https://hoppscotch.com";
    downloadPage = "https://hoppscotch.com/downloads";
    changelog = "https://hoppscotch.com/changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [matthewpi];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
