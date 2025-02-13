{
  inputs,
  lib,
  pkgs,
  cfg,
  outputs,
  ...
}: {
  home.sessionVariables = lib.mkMerge [
    {
      # nix
      NIX_CONFIG = "experimental-features = nix-command flakes";
      NIXPKGS_ALLOW_UNFREE = "1";

      # shell
      EDITOR = "nano";
      TZ = "Europe/Budapest";
      SHELL = "${pkgs.zsh}/bin/zsh";

      # k9s
      K9S_FEATURE_GATE_NODE_SHELL = "true";

      # corepack
      COREPACK_ENABLE_AUTO_PIN = "0";
    }
    (cfg.env or {})
  ];
}
