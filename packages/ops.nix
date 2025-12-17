pkgs: with pkgs; [
  gh
  (pkgs.google-cloud-sdk.withExtraComponents [
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
    pkgs.google-cloud-sdk.components.pubsub-emulator
  ])
  google-cloud-sql-proxy
  go-containerregistry
  helmfile
  k9s
  kubectl
  kubectl-view-allocations
  kubectx
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
  teller
  terraform
  terragrunt
]
