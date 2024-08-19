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
    plugin = {
      plugins = {
        debug = {
          shortCut = "Shift-D";
          description = "Add debug container";
          dangerous = true;
          scopes = [ "containers" ];
          command = "bash";
          background = false;
          confirm = true;
          args = [
            "-c"
            "kubectl debug -it --context $CONTEXT -n=$NAMESPACE $POD --target=$NAME --image=nicolaka/netshoot:v0.12 --share-processes -- bash"
          ];
        };
      };
    };
  };
}