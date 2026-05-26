{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  programs.k9s = {
    enable = true;
    plugins = {
      plugins = {
        debug = {
          shortCut = "Shift-D";
          description = "Add debug container";
          dangerous = true;
          scopes = [ "containers" ];
          command = "kubectl";
          background = false;
          confirm = true;
          args = [
            "debug"
            "-it"
            "--context"
            "$CONTEXT"
            "-n=$NAMESPACE"
            "$POD"
            "--target=$NAME"
            "--image=nicolaka/netshoot:v0.12"
            "--share-processes"
            "--profile=general"
            "--"
            "bash"
          ];
        };
        force-sync-externalsecret = {
          shortCut = "Ctrl-F";
          description = "Force sync ExternalSecret";
          scopes = [ "externalsecrets" ];
          command = "kubectl";
          background = false;
          args = [
            "annotate"
            "externalsecret"
            "$NAME"
            "force-sync=$MOMENT"
            "--overwrite"
            "-n=$NAMESPACE"
          ];
        };
        force-reconcile-kustomization = {
          shortCut = "Ctrl-R";
          description = "Force reconcile Flux Kustomization";
          scopes = [ "pods" ];
          command = "kubectl";
          background = false;
          args = [
            "annotate"
            "kustomization"
            "$NAME"
            "reconcile.fluxcd.io/requestedAt=$MOMENT"
            "--overwrite"
            "-n=$NAMESPACE"
          ];
        };
      };
    };
  };
}
