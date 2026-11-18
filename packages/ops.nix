pkgs: with pkgs; [
  antigravity-cli
  (pkgs.azure-cli.withExtensions [
    pkgs.azure-cli.extensions.azure-devops
  ])
  bws
  claude-code
  cloudflare-cli
  coderabbit-cli
  codex
  gh
  github-copilot-cli
  # (pkgs.google-cloud-sdk.withExtraComponents [
  #   pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
  #   pkgs.google-cloud-sdk.components.pubsub-emulator
  # ])
  # google-cloud-sql-proxy
  go-containerregistry
  helmfile
  k9s
  kubectl
  kubectl-view-allocations
  kubectx
  kubelogin
  kustomize
  krew
  (pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = [
      #pkgs.kubernetes-helmPlugins.helm-secrets
      pkgs.kubernetes-helmPlugins.helm-git
      pkgs.kubernetes-helmPlugins.helm-diff
      pkgs.kubernetes-helmPlugins.helm-unittest
    ];
  })
  labctl
  oci-cli
  railway
  render-cli
  sentry-cli
  sofka
  supabase-cli
  terraform
  terragrunt
]
