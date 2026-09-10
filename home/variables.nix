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
      PAGER = "less";
      # -R: keep colors, --mouse: scroll wheel / touch scrolling,
      # --wheel-lines: lines per scroll step, -F/-X: don't page short output
      LESS = "-R -F -X --mouse --wheel-lines=3";
      TZ = "Europe/Budapest";
      SHELL = "${pkgs.zsh}/bin/zsh";

      # k9s
      K9S_FEATURE_GATE_NODE_SHELL = "true";

      # corepack
      COREPACK_ENABLE_AUTO_PIN = "0";

      # azure
      AZURE_CORE_OUTPUT = "table";
    }
    (cfg.env or {})
  ];
}
