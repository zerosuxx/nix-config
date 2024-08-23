{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  home.sessionVariables = {
    # nix
    NIX_CONFIG = "experimental-features = nix-command flakes";

    # shell
    EDITOR = "nano";
    TZ = "Europe/Budapest";

    # k9s
    K9S_FEATURE_GATE_NODE_SHELL = "true";
  };
}
