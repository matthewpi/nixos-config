{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
}:
buildGoModule rec {
  pname = "kind";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "kind";
    rev = "v${version}";
    hash = "sha256-1bU4vHC9bVz8TfO7knO1RYRxJUnwsXxZrRVnit5iQz0=";
  };

  patches = [
    # fix kernel module path used by kind
    ./kernel-module-path.patch
  ];

  vendorHash = "sha256-VfqNM48M39R2LaUHirKmSXCdvBXUHu09oMzDPmAQC4o=";

  nativeBuildInputs = [installShellFiles];

  subPackages = ["."];

  env.CGO_ENABLED = 0;

  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd ${meta.mainProgram} \
      --bash <("$out"/bin/${meta.mainProgram} completion bash) \
      --fish <("$out"/bin/${meta.mainProgram} completion fish) \
      --zsh  <("$out"/bin/${meta.mainProgram} completion zsh)
  '';

  meta = {
    mainProgram = "kind";
    description = "Kubernetes IN Docker - local clusters for testing Kubernetes";
    homepage = "https://github.com/kubernetes-sigs/kind";
    maintainers = with lib.maintainers; [matthewpi];
    license = lib.licenses.asl20;
  };
}
