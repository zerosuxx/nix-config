pkgs: with pkgs; [
  kubectl
  kubectx
  (pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = [
      #pkgs.kubernetes-helmPlugins.helm-secrets
      pkgs.kubernetes-helmPlugins.helm-git
      pkgs.kubernetes-helmPlugins.helm-diff
      pkgs.kubernetes-helmPlugins.helm-unittest
    ];
  })
  helmfile
  k9s
  (pkgs.google-cloud-sdk.withExtraComponents [
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
  ])
  gh
  google-cloud-sql-proxy
  go-containerregistry
  teller
  terraform
  terragrunt
]
