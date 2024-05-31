pkgs: with pkgs; [
  kubectl
  (pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = [
      #pkgs.kubernetes-helmPlugins.helm-secrets
      pkgs.kubernetes-helmPlugins.helm-diff
      pkgs.kubernetes-helmPlugins.helm-unittest
    ];
  })
  helmfile
  k9s
  (pkgs.google-cloud-sdk.withExtraComponents ([
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
  ]))
  google-cloud-sql-proxy
  #(pkgs.callPackage "${builtins.fetchGit {
  #  url = "https://github.com/Ch4s3r/nixpkgs.git";
  #  ref = "main";
  #}}/docker-desktop" { })
]
