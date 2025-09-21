{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "freelens-k8s-proxy";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "freelensapp";
    repo = "freelens-k8s-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nozD3lM7q2obiGCOFZdrb9YsW3Z8kWand1e4W6MLunk=";
  };

  vendorHash = "sha256-undapU07xxQze8fx10kvNenFlMYExZwkkuZAvqnKR3w=";

  # I love Go, except for the decision to pin the Go version in `go.mod`.
  #
  # If we are below the version specified in the `go.mod`, even by a single
  # minor, the build will fail.
  prePatch = ''
    substituteInPlace go.mod --replace-fail 'go 1.25.1' 'go 1.25.0'
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
