{
  buildGoModule,
  fetchFromGitHub,
  go,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "freelens-k8s-proxy";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "freelensapp";
    repo = "freelens-k8s-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WPC+c27XWPBey4JBZJRCjqY/81ip6YYpsax3A/Ih5n0=";
  };

  vendorHash = "sha256-wjvA8KlXdR998mTjNnoPUO/1Ch0YTbxleX8gEvxhOrI=";

  # I love Go, except for the decision to pin the Go version in `go.mod`.
  #
  # If we are below the version specified in the `go.mod`, even by a single
  # minor, the build will fail.
  prePatch = ''
    substituteInPlace go.mod --replace-fail 'go 1.26.4' 'go ${go.version}'
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
