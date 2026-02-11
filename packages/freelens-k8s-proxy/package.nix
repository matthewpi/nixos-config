{
  buildGoModule,
  fetchFromGitHub,
  go,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "freelens-k8s-proxy";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "freelensapp";
    repo = "freelens-k8s-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IVledYSL7ZSGAkM+2zyQYjedI5usCvHObtld9gADfik=";
  };

  vendorHash = "sha256-FmGozz3u6pbhRA49/S8dO/N5plqv3Zi3ohXHzrcWmmg=";

  # I love Go, except for the decision to pin the Go version in `go.mod`.
  #
  # If we are below the version specified in the `go.mod`, even by a single
  # minor, the build will fail.
  prePatch = ''
    substituteInPlace go.mod --replace-fail 'go 1.26.0' 'go ${go.version}'
  '';

  env.CGO_ENABLED = 0;
  ldflags = ["-X main.version=${finalAttrs.src.tag}"];

  meta = {
    mainProgram = "freelens-k8s-proxy";
    description = "More secure alternative to `kubectl proxy`";
    homepage = "https://github.com/freelensapp/freelens-k8s-proxy";
    changelog = "https://github.com/freelensapp/freelens-k8s-proxy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [matthewpi];
  };
})
