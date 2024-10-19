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
    NIXPKGS_ALLOW_UNFREE = "1";

    # shell
    EDITOR = "nano";
    TZ = "Europe/Budapest";
    SHELL = "${pkgs.zsh}/bin/zsh";

    # k9s
    K9S_FEATURE_GATE_NODE_SHELL = "true";
  };
}
