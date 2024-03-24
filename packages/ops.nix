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
]
